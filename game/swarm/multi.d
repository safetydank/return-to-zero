module game.swarm.multi;

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

//  A multiplying swarm, think "Asteroids"
class MultiSwarm : Swarm
{
  Texture _texture;
  Ship _ship;

  int _c_rendered;
  float _scaleFactor = 0.7f;

  Vector _bright;
  Vector _dark;
  Vector _color;

  public this(NullGameManager gm, int c_members)
  {
    super(gm, c_members);
    _bright = Vector.create(1., 0.9, .80, 1.0);
    _dark = Vector.create(0.95, 1.0, 0.02, 0.2);  
  }

  public void init(VertexBuffer!(Vertex) vb, Texture t, Vector color)
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
        float scale = b.radius * 2.0;
        auto attr = ShapeAttr.create(b.pos, _color, Vector.create(scale, scale), 
            Matrix.rotationZ(-b.heading));
        i = _gm.shaper.writeBillboard(_vertices, i, attr);
        ++c_drawn;
      }
    }

    if (c_drawn > 0)
      _vb.writeBatch(GL_TRIANGLES, cast(void*) _vertices.ptr, c_drawn * 6);

    return c_drawn;
  }

  void moveBody(SwarmBody b, float elapsed)
  {
    b.boundingCircle.prev = b.pos;
    b.pos += b.vel;
    b.boundingCircle.pos = b.pos;
    b.heading = b.heading + b.ang;

    //  Bounce towards ship
    if (!_lm.field.inField(b.pos))
    {
      _lm.field.clampToField(b.pos);
      setHeading(b);
    }

    if (_lm.field.inField(b.pos) == false)
      b.exists = false;
  }

  void addMulti(Vector pos, Vector vel, float radius, int hits = 10, float scaleBound = 1.0)
  {
    auto b = _bodies.getInstance();
    if (b !is null)
    {
      b.boundingCircle = BoundingCircle.create(radius*scaleBound, pos, pos);
      b.exists = true;
      b.vel = vel;
      b.pos = pos;
      b.hits = hits;
      b.heading = _rand.nextFloat(2*PI);
      b.ang = _rand.nextFloat(-0.1, 0.1);
      b.radius = radius;
    }
  }

  public void hit(SwarmBody bdy, Vector dir)
  {
    _gm.levelManager.score.add(bdy.hits * 128);

    --bdy.hits;

    if (bdy.hits > 3)
    {
      Vector ricPos = bdy.pos - (bdy.boundingCircle.radius * dir);
      _lm.explosion.addRicochet(ricPos, -dir, 16, 0.1*PI, 0.35, 0.4, _bright, _dark);
      SoundManager.playSe("spark");
    }
    else if (bdy.hits > 0)
    {
      Vector rnd1 = _gm.levelManager.rndVectorXY(0.2f);
      Vector rnd2 = -_gm.levelManager.rndVectorXY(0.2f);

      _lm.flash.addFlash(bdy.pos, bdy.boundingCircle.radius, 0.05);

      addMulti(bdy.pos, rnd1, bdy.boundingCircle.radius * _scaleFactor, bdy.hits);
      addMulti(bdy.pos, rnd2, bdy.boundingCircle.radius * _scaleFactor, bdy.hits);
      bdy.exists = false;
    }
    else
    {
      _lm.explosion.addRandomExplosion(bdy.pos, 15, 0.4, 1.2, _bright, _dark);
      bdy.exists = false;
      SoundManager.playSe("destroyed");
    }

    if (bdy.hits == 3)
      SoundManager.playSe("boom");
  }

  void setHeading(SwarmBody bdy)
  {
    float speed = bdy.vel.length;
    bdy.vel = speed * normalize(_ship.pos - bdy.pos);
  }

  public void collidedWithPlayer(SwarmBody bdy)
  {
  }
}

