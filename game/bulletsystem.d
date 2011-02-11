module game.bulletsystem;

import std.file;
import std.string;

import core.logger;
import core.rand;
import core.util;

import de.math;
import de.texture;
import de.vertexbuffer;
import de.vertex;
import de.actor;
import de.shader;
import de.shaper;
import de.collision;
import de.screen;
import de.pool;
import de.vertexset;

import derelict.opengl.gl;

// XXX bug - when we use NullGameManager instead of GameManager there are
// linking errors!
import de.gamemanager;

//  A collection of bullets
class BulletSystem
{
  ActorPool!(Bullet) _bullets;
  public ActorPool!(Bullet) bullets() { return _bullets; }

  //  Internal buffers
  VertexBuffer!(Vertex) _vertexBuffer;
  Vertex[] _vertices;

  //  Rendering
  private Texture _texture;
  Vector _color;
  public Texture texture(Texture t) { return _texture = t; }
  GameManager _gm;

  int _c_members;

  this(GameManager gm, int c_members)
  {
    _c_members = c_members;
    _gm = gm;
  }

  public void init(Vector color)
  out
  {
    assert(_texture);
  }
  body
  {
    //  Create rendering buffer and internal buffer
    _vertexBuffer = new VertexBuffer!(Vertex)(_c_members * 6);
    _vertices = new Vertex[_c_members * 6];    
    _bullets = new ActorPool!(Bullet)(_c_members);
    _texture = _gm.textures["bullet"];
    _color = color;
  }

  public void deactivate()
  {
    foreach (b; _bullets)
    {
      b.exists = false;
    }
  }

  public void move(float elapsed)
  {
    foreach (Bullet bullet; _bullets)
    {
      bullet.move(elapsed);
    }
  }

  public void draw()
  {
    if (renderToVertexBuffer())
    {
      _texture.bind();
      _vertexBuffer.drawBatch();
      Texture.unbind();
    }
  }

  int renderToVertexBuffer()
  {
    int i = 0;
    int c_drawn = 0;

    foreach (bullet; _bullets)
    {
      if (bullet.exists)
      {
        float dir = heading(bullet.vel.x, bullet.vel.y);
        float scale = bullet.radius * 2.0;
        auto attr = ShapeAttr.create(bullet.pos, _color, Vector.create(scale, scale), 
            Matrix.rotationZ(-dir));
        _gm.shaper.writeBillboard(_vertices, i, attr);
        ++c_drawn;
        i += 6;
      }
    }

    if (c_drawn > 0)
    {
      _vertexBuffer.writeBatch(GL_TRIANGLES, _vertices.ptr, c_drawn * 6);
      // Logger.instance.message(format("Drew %d bullets vertices: %d", c_drawn, c_drawn * 6));
    }

    return c_drawn;
  }

  void writeBillboard(int i, float radius, Vector pos, Vector color)
  {
    _vertices[i++] = Vertex.create(0, 0, color, -radius + pos.x,  radius + pos.y, 0);
    _vertices[i++] = Vertex.create(0, 1, color, -radius + pos.x, -radius + pos.y, 0);
    _vertices[i++] = Vertex.create(1, 1, color,  radius + pos.x, -radius + pos.y, 0);
    _vertices[i++] = Vertex.create(0, 0, color, -radius + pos.x,  radius + pos.y, 0);
    _vertices[i++] = Vertex.create(1, 1, color,  radius + pos.x, -radius + pos.y, 0);
    _vertices[i++] = Vertex.create(1, 0, color,  radius + pos.x,  radius + pos.y, 0);
  }

  void shoot(Vector pos, Vector vel)
  {
    Bullet b = _bullets.getInstance();
    if (b !is null)
    {
      b.exists = true;
      b.pos = pos;
      b.vel = vel;
//      Logger.instance.message(format("Shot from %s vel %s", b.pos.toString, 
//        b.vel.toString));
    }
  }
}

class Bullet : Actor
{
  protected Vector _pos;
  protected BoundingCircle _circle;

  public Vector vel;
  float  radius = 0.4f;

  public BoundingCircle boundingCircle() { return _circle; }

  public Vector pos(Vector v)
  {
    _pos = v;
    _circle.pos = v;
    _circle.prev = v;

    return _pos;
  }

  public Vector pos() { return _pos; }

  public void init(Object[] args)
  {
    _circle.radius = radius;
    exists = false;
  }

  public void move(float elapsed)
  {
    if (exists)
    {
      _circle.prev = _pos;
      _pos += vel;
      _circle.pos = _pos;

      if (_pos.x * _pos.x + _pos.y * _pos.y > 60.0 * 60.0)
        exists = false;
    }
  }

  public void hit()
  {
    exists = false;
  }
}
