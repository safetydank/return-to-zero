module game.swarm.flash;

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

//  Stores positions of flashes to be rendered each turn
class FlashSwarm : Swarm
{
  Texture _texture;

  int _c_rendered;

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
      // _gm.feedbackBuffer.bind();
      // _gm.feedbackBuffer.setPerspective();
      // glBlendFunc(GL_SRC_ALPHA, GL_ONE);
      _texture.bind();
      _vb.drawBatch();
      Texture.unbind();
      // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      // _gm.feedbackBuffer.unbind();
      // _gm.screen.setPerspective();
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
        float m = cos_interp(0.9, 0.6, b.t / b.lifetime);
        Vector color = m * Vector.create(1.0, 1.0, 1.0, 1.0);
        float scale = b.boundingCircle.radius * 2.0;
        auto attr = ShapeAttr.create(b.boundingCircle.pos, color, scale);
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
    if (b.t > b.lifetime)
    {
      b.t = 0;
      b.exists = false;
    }
  }

  public void addFlash(Vector pos, float radius, float lifetime)
  {
    addFlash(pos, radius, lifetime, Vector.create(1., 1., 1., 1.));
  }

  public void addFlash(Vector pos, float radius, float lifetime, Vector color)
  {
    auto b = _bodies.getInstance();
    if (b !is null)
    {
      b.exists = true;
      b.t = 0;
      b.boundingCircle = BoundingCircle.create(radius, pos, pos);
      b.lifetime = lifetime;
      //  Use force field for colour
    }
  }

  public void hit(SwarmBody bdy, Vector dir)
  {
  }

  public void collidedWithPlayer(SwarmBody bdy)
  {
  }
}

