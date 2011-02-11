module game.swarm.explosion;

import std.string;

import core.interpolate;

import de.collision;
import de.math;
import de.texture;
import de.vertex;
import de.vertexbuffer;
import de.shaper;

import derelict.opengl.gl;

import game.ship;
import game.swarm.swarm;
import game.gamemanager;

//  An explosion renderer
class ExplosionSwarm : Swarm
{
  Texture _texture;
  // VertexBuffer!(Vertex) _vb_flash;

  int _c_rendered;

  //  c_members defines the max particles rendered by a swarm
  public this(NullGameManager gm, int c_members)
  {
    super(gm, c_members);
  }

  public void init(VertexBuffer!(Vertex) vb, Texture t)
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
        float alpha = b.t / b.lifetime;
        Vector color = linear_interp(b.bright, b.dark, alpha);
        auto attr = ShapeAttr.create(b.pos, color, 0.37f);
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
    b.prev = b.pos;
    b.pos += b.vel;
    b.t += elapsed;

    if (b.t >= b.lifetime || b.pos.lengthSq > 50.0 * 50.0)
    {
      b.exists = false;
    }
  }

  void addFlash()
  {
  }

  public void addRandomExplosion(Vector pos, int c_particles, float speed, float lifetime,
    Vector bright, Vector dark)
  {
    for (int i = 0; i < c_particles; ++i)
    {
      Vector vel = _lm.rndVectorXY(-speed, speed);
      addParticle(pos, vel, lifetime, bright, dark);
    }
  }

  //  dispersion angle in radians
  public void addRicochet(Vector pos, Vector dir, int c_particles, float
      dispersion, float speed, float lifetime, Vector bright, Vector dark)
  {
    for (int i = 0; i < c_particles; ++i)
    {
      float heading = -heading(dir.x, dir.y) - PI/2 + _rand.nextFloat(-dispersion, dispersion);
      Vector vel = -speed * Vector.create(cos(heading), sin(heading));
      float r = _rand.nextFloat(0.5, 1.5);
      addParticle(pos, r * vel, lifetime, bright, dark);
    }
  }

  public void addRadialExplosion(Vector pos, int c_particles, float speed,
      float lifetime, Vector bright, Vector dark)
  {
    for (int i = 0; i < c_particles; ++i)
    {
      float heading = (i * 2.0f * PI) / c_particles;
      Vector vel = speed * Vector.create(cos(heading), sin(heading));
      addParticle(pos, vel, lifetime, bright, dark);
    }
  }

  void addParticle(Vector pos, Vector vel, float lifetime, Vector bright, Vector dark)
  {
    auto b = _bodies.getInstance();
    if (b !is null)
    {
      b.exists = true;
      b.t = 0;

      b.pos = pos;
      b.vel = vel;
      b.lifetime = lifetime;
      b.bright = bright;
      b.dark   = dark;
    }
  }

  public void hit(SwarmBody bdy, Vector dir)
  {
    //  no collision detection with explosions
  }

  public void collidedWithPlayer(SwarmBody bdy)
  {
    //  no collision detection with explosions
  }
}

