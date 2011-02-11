module game.swarm.swarm;

import std.file;
import std.string;

import core.logger;
import core.rand;

import de.math;
import de.texture;
import de.screen;
import de.vertexbuffer;
import de.vertex;
import de.actor;
import de.collision;
import de.shaper;
import de.gamemanager;
import de.physicsbody;
import de.pool;

import derelict.opengl.gl;

import game.gamemanager;
import game.levelmanager;

//  A swarm of enemies
class Swarm
{
  protected Rand _rand;
  protected NullGameManager _gm;
  protected LevelManager _lm;
  protected Logger _log;

  // XXX make bodies return an interface to a collection of collision bodies ???
  protected Pool!(SwarmBody) _bodies;
  public Pool!(SwarmBody) bodies() { return _bodies; }

  //  Internals buffers
  protected int _c_members;
  protected VertexBuffer!(Vertex) _vb;
  protected Vertex[] _vertices;

  int _c_active = 0;
  public int c_active() { return _c_active; }

  this(NullGameManager gm, int c_members)
  in
  {
    assert(gm);
  }
  out
  {
    assert(_lm);
  }
  body
  {
    _gm = gm;
    _lm = gm.levelManager;
    _log = Logger.instance;
    _c_members = c_members;

    initBodies();
    initVertexBuffer();
  }

  protected void initBodies()
  {
    _bodies  = new Pool!(SwarmBody)(_c_members);
  }

  protected void initVertexBuffer()
  {
    _vertices = new Vertex[_c_members * 6];    
  }

  public void reset(VertexBuffer!(Vertex) vb)
  {
    _vb = vb;
  }

  public void init()
  out
  {
    assert(_vb);
    assert(_vertices);
  }
  body
  {
    _rand = new Rand();

    //  Create rendering buffer and internal buffer
    _vb = new VertexBuffer!(Vertex)(_c_members * 6);
  }

  public void deactivate()
  {
    foreach (bdy; _bodies)
      bdy.exists = false;
  }

  public abstract void move(float elapsed);
  public abstract void draw();
  public abstract void hit(SwarmBody bdy, Vector dir);
  public abstract void collidedWithPlayer(SwarmBody bdy);
}

//  A basic swarm body
public class SwarmBody
{
  Vector pos;
  Vector prev;
  Vector vel;
  Vector force;

  float  t;
  float  lifetime;

  float  speed;
  float  heading;
  BoundingCircle boundingCircle;
  bool   exists;

  int    hits;
  int    powerup;
  int    type;
  bool   feedback;

  float  radius;
  float  toRadius;
  float  ang;

  Vector bright;
  Vector dark;
}

