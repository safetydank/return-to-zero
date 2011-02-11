module game.swarm.dumb;

import std.string;

import de.collision;
import de.math;
import de.texture;
import de.vertex;
import de.vertexbuffer;
import de.shaper;
import de.sound;

import derelict.opengl.gl;

import game.ship;
import game.swarm.swarm;
import game.gamemanager;

//  A dumb swarm, just tracks the ship and moves towards it slowly
class DumbSwarm : Swarm
{
  Texture _texture;
  Ship _ship;
  float _radius;

  int _c_rendered;

  Vector _bright;
  Vector _dark;

  Vector _color;

  public this(NullGameManager gm, int c_members)
  {
    super(gm, c_members);
    _bright = Vector.create(1., 1., .57, 1.0);
    _dark = Vector.create(0.37, 0.13, 0.15, 0.2);  
  }

  public void init(VertexBuffer!(Vertex) vb, Texture t, float radius)
  {
    init(vb, t, radius, Vector.create(1., 0.8, 0.6, 0.9));
  }

  public void init(VertexBuffer!(Vertex) vb, Texture t, float radius, Vector color)
  out
  {
    assert(_vb.c_bufVertices >= _c_members * 6);
    assert(_texture);
  }
  body
  {
    super.init();
    _vb = vb;
    _texture = t;
    _radius = radius;
    _color = color;

    _ship = _gm.levelManager.ship;
  }

  public void draw()
  in
  {
    assert(_vb);
    assert(_texture);
  }
  body
  {
    if (_c_rendered > 0)
    {
      _texture.bind();
      _vb.drawBatch();

      Texture.unbind();
    }
  }

  public void move(float elapsed)
  {
    _c_active = 0;
    foreach (b; _bodies)
    {
      ++_c_active;
      setHeading(b, _ship.pos);
      moveBody(b, elapsed);
    }

    _c_rendered = render();
  }

  //  Render enemies to vertexbuffer.  Returns the count rendered.
  int render()
  {
    int i = 0;
    int c_drawn = 0;

    foreach (b; _bodies)
    {
      if (b.exists)
      {
        Vector v = b.pos - _ship.pos;
        float dir = heading(v.x, v.y) + PI;
        float scale = b.boundingCircle.radius * 2.0;
        auto attr = ShapeAttr.create(b.pos, _color, Vector.create(scale, scale), 
            Matrix.rotationZ(-dir));
        i = _gm.shaper.writeBillboard(_vertices, i, attr);
        ++c_drawn;
      }
    }

    if (c_drawn > 0)
      _vb.writeBatch(GL_TRIANGLES, cast(void*) _vertices.ptr, c_drawn * 6);

    return c_drawn;
  }

  void setHeading(SwarmBody b, Vector dst)
  {
    b.vel = b.speed * normalize(dst - b.pos);
  }

  void moveBody(SwarmBody b, float elapsed)
  {
    b.boundingCircle.prev = b.pos;
    b.pos += b.vel;
    b.boundingCircle.pos = b.pos;

    if (b.pos.x * b.pos.x + b.pos.y * b.pos.y > 50.0 * 50.0)
      b.exists = false;
  }

  void addEnemy(Vector pos, float speed)
  {
    auto b = _bodies.getInstance();
    if (b !is null)
    {
      b.boundingCircle = BoundingCircle.create(_radius, pos, pos);
      b.exists = true;
      b.speed = speed;
      b.pos = pos;
    }
  }

  public void hit(SwarmBody bdy, Vector dir)
  {
    _lm.explosion.addRandomExplosion(bdy.pos, 8, 0.02, 1.0, _bright, _dark);
    _lm.flash.addFlash(bdy.pos, 0.8, 0.05);
    bdy.exists = false;
    SoundManager.playSe("destroyed");
    _gm.levelManager.score.add(128);
  }

  public void collidedWithPlayer(SwarmBody bdy)
  {
  }
}

