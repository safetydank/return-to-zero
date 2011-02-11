module game.swarm.balloon;

import std.string;

import core.interpolate;

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
import game.bulletsystem;
import game.gamemanager;

//  A balloon "inflates" with bullets then releases it's payload
class BalloonSwarm : Swarm
{
  Texture _texture;
  Ship _ship;

  int _c_rendered;
  float _scaleFactor = 0.7f;

  Vector _bright;
  Vector _dark;

  BulletSystem _bullets;

  public this(NullGameManager gm, int c_members)
  {
    super(gm, c_members);
    _bright = Vector.create(1., 0.9, .80, 1.0);
    _dark = Vector.create(0.95, 1.0, 0.02, 0.2);  
  }

  public void init(VertexBuffer!(Vertex) vb, Texture t, BulletSystem bullets)
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
    _bullets = bullets;
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
      // setHeading(b, _ship.pos);
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
        Vector color = Vector.create(1.0, 0.8, 0.4, 1.0);
        Vector v = b.pos - _ship.pos;
        float dir = heading(v.x, v.y);
        float scale = b.boundingCircle.radius * 2.0;
        auto attr = ShapeAttr.create(b.pos, color, Vector.create(scale, scale), 
            Matrix.rotationZ(-dir));
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
    b.t += elapsed;
    if (b.t < b.lifetime)
      b.boundingCircle.radius = cos_interp(b.radius, b.toRadius, b.t/b.lifetime);
    else
      b.radius = b.toRadius;

    b.boundingCircle.prev = b.pos;
    b.pos += b.vel;
    b.boundingCircle.pos = b.pos;

    //  Bounce towards ship
    if (!_lm.field.inField(b.pos))
    {
      _lm.field.clampToField(b.pos);
      setHeading(b);
    }

    if (_lm.field.inField(b.pos) == false)
      b.exists = false;
  }

  void addBalloon(Vector pos, Vector vel, float radius, int hits = 10)
  {
    auto b = _bodies.getInstance();
    if (b !is null)
    {
      b.boundingCircle = BoundingCircle.create(radius, pos, pos);
      b.exists = true;
      b.vel = vel;
      b.pos = pos;
      b.hits = hits;
      b.t = 0;
      b.lifetime = 0.4;
      b.radius = radius;
      b.toRadius = radius;
    }
  }

  public void hit(SwarmBody bdy, Vector dir)
  {
    _gm.levelManager.score.add(bdy.hits * 256);

    --bdy.hits;

    if (bdy.hits > 0)
    {
      bdy.t = 0;
      bdy.radius = bdy.boundingCircle.radius;
      bdy.toRadius *= 1.1f;
    }
    else
    {
      int c_bullets = 4;
      for (int i = 0; i < c_bullets; ++i)
      {
        float heading = ((i * 2.0f * PI) / c_bullets) + PI_4;
        Vector vel = 0.2 * Vector.create(cos(heading), sin(heading));
        _lm.bullets[0].shoot(bdy.pos, vel);
        _lm.flash.addFlash(bdy.pos, bdy.boundingCircle.radius * 0.5f, 0.04);
      }
      bdy.exists = false;
    }

    SoundManager.playSe("destroyed");
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

