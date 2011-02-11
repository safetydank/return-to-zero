module game.swarm.cascade;

import std.string;

import de.collision;
import de.math;
import de.texture;
import de.vertex;
import de.vertexbuffer;
import de.shaper;
import de.physicsbody;
import de.sound;

import derelict.opengl.gl;

import game.ship;
import game.swarm.swarm;
import game.gamemanager;

//  A cascading swarm of physics bodies
class CascadeSwarm : Swarm
{
  Texture _texture;
  Ship _ship;

  int _c_rendered;
  float _scaleFactor = 0.7f;

  ForceBody _fbody;
  float _clock = 0;

  Vector _bright;
  Vector _dark;

  Vector _color;

  float _radius;
  float _speed;

  public this(NullGameManager gm, int c_members)
  {
    super(gm, c_members);
    _fbody = new ForceBody();
    _bright = Vector.create(0.81, 1., 0.89, 1.0);
    _dark = Vector.create(0.20, 0.25, 0.22, 0.2);  
  }

  public void init(VertexBuffer!(Vertex) vb, Texture t, Vector color, float radius, float speed)
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

    _ship = _lm.ship;
    _color = color;
    _radius = radius;
    _speed = speed;
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
    _clock += elapsed;

    _c_active = 0;
    foreach (b; _bodies)
    {
      ++_c_active;
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

  // void setHeading(SwarmBody b, Vector dst)
  // {
  //   b.vel = b.speed * normalize(dst - b.pos);
  // }

  public void start(int num, bit top)
  {
    for (int i=0; i < num; ++i)
    {
      auto b = _bodies.getInstance();
      if (b is null)
        continue;

      float _startX = (i * _lm.field.FIELD_WIDTH / num) - _lm.field.FIELD_HEIGHT * 0.5f;
      float _startY = _lm.field.FIELD_HEIGHT / 2.0f;
      if (!top) _startY *= -1.0;
      Vector startPos = Vector.create(_startX, _startY);

      b.boundingCircle = BoundingCircle.create(_radius, startPos, startPos);
      b.exists = true;
      b.vel = Vector.create(0, -_speed);
      if (!top) b.vel *= -1.0;
      b.pos = startPos;
      b.force = Vector.create(0, -10.0, 0) + _lm.rndVectorXY(-2.0, 2.0);
      if (!top) b.force *= -1.0;
    }
  }

  void moveBody(SwarmBody b, float elapsed)
  {
    b.boundingCircle.prev = b.pos;

    _fbody.init(_clock, b.pos, b.vel);
    _fbody.force = b.force;
    _fbody.moveWith(b, elapsed);
    b.boundingCircle.pos = b.pos;

    if (_lm.field.inField(b.pos) == false)
      b.exists = false;
  }

  public void hit(SwarmBody bdy, Vector dir)
  {
    _gm.levelManager.score.add(bdy.hits * 128);
    _lm.explosion.addRadialExplosion(bdy.pos, 10, 0.4, 1.0, _bright, _dark);
    _lm.flash.addFlash(bdy.pos, 0.5, 0.05);
    bdy.exists = false;
    SoundManager.playSe("destroyed");
  }

  public void collidedWithPlayer(SwarmBody bdy)
  {
  }
}


