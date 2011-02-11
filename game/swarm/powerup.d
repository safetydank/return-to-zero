module game.swarm.powerup;

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

const int COLLECTED = -1;
const int WEAPON = 0;
const int HEALTH = 1;

//  Powerups for collection
class PowerupSwarm : Swarm
{
  VertexBuffer!(Vertex) _vb;
  Texture _texture;

  protected Vertex[] _healthVertices;
  protected Vertex[] _weaponVertices;

  int _c_rendered;

  const float POWERUP_RADIUS = 0.5;

  public this(NullGameManager gm, int c_members)
  {
    super(gm, c_members);
  }

  public void init(Texture t)
  out
  {
    assert(_vb.c_bufVertices >= _c_members * 6);
    assert(_texture);
  }
  body
  {
    super.init();
    _vb = new VertexBuffer!(Vertex)(_c_members * 6);
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

  //  Render to vertexbuffer.  Returns the count rendered.
  int render()
  {
    int i = 0;
    int c_drawn = 0;

    foreach (b; _bodies)
    {
      if (b.exists)
      {
        float m = cos_interp(1.0, 0.1, b.t / b.lifetime);
        Vector color = m * Vector.create(1.0, 1.0, 1.0, 1.0);
        float scale = 0;
        if (b.powerup == COLLECTED)
        {
          float k = cos_interp(1.0f, 3.0f, b.t / b.lifetime);
          scale = k * POWERUP_RADIUS * 2.0;
        }
        else
        {
          scale = POWERUP_RADIUS * 2.0;
        }

        auto attr = ShapeAttr.create(b.boundingCircle.pos, color, scale);

        //  XXX hack
        int newIndex = _gm.shaper.writeBillboard(_vertices, i, attr);

        int type = b.powerup;
        if (type == COLLECTED) type = b.type;
        if (type == WEAPON)
        {
          Vertex.setTexture(_vertices[i+0], 0, 0);
          Vertex.setTexture(_vertices[i+1], 0, 0.5);
          Vertex.setTexture(_vertices[i+2], 0.5, 0.5);
          Vertex.setTexture(_vertices[i+3], 0, 0);
          Vertex.setTexture(_vertices[i+4], 0.5, 0.5);
          Vertex.setTexture(_vertices[i+5], 0.5, 0);
        }
        else if (type == HEALTH)
        {
          Vertex.setTexture(_vertices[i+0], 0.5, 0);
          Vertex.setTexture(_vertices[i+1], 0.5, 0.5);
          Vertex.setTexture(_vertices[i+2], 1.0, 0.5);
          Vertex.setTexture(_vertices[i+3], 0.5, 0);
          Vertex.setTexture(_vertices[i+4], 1.0, 0.5);
          Vertex.setTexture(_vertices[i+5], 1.0, 0);
        }

        i = newIndex;

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

  public void addPowerup(Vector pos, int type, float lifetime = 10.0)
  {
    auto b = _bodies.getInstance();
    if (b !is null)
    {
      b.exists = true;
      b.t = 0;
      b.lifetime = lifetime;
      b.boundingCircle.pos = pos;
      b.boundingCircle.prev = pos;
      b.boundingCircle.radius = POWERUP_RADIUS;
      b.powerup = type;
    }
  }

  public void hit(SwarmBody bdy, Vector dir)
  {
  }

  public void collidedWithPlayer(SwarmBody bdy)
  {
  }
}

