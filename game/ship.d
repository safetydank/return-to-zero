module game.ship;

import core.util;
import core.logger;

import de.math;
import de.actor;
import de.vertex;
import de.vertexbuffer;
import de.texture;
import de.shaper;
import de.shader;
import de.screen;
import de.twinstickpad;
import de.collision;
import de.sound;
import de.mouse;

import derelict.opengl.gl;

import game.gamemanager;
import game.bulletsystem;
import game.field;
import game.swarm.powerup;

class Ship
{
  TwinStickPad _pad;
  Mouse _mouse;
  private Vector _pos;
  Screen _screen;
  VertexBuffer!(Vertex) _vb_ship;
  Texture _texture;
  int wickets;

  BulletSystem _bulletSystem;
  public BulletSystem bulletSystem() { return _bulletSystem; }

  NullGameManager _gm;
  Field _field;

  BoundingCircle _boundingCircle;
  public BoundingCircle boundingCircle() { return _boundingCircle; }

  const float NORMAL_BULLET_DELAY = 0.12f;
  const float INVULNERABLE_TIME = 2.0;

  float shipSpeed   = 0.22;
  float bulletSpeed = 0.80;
  float bulletDelay = NORMAL_BULLET_DELAY;

  float _stretch = 1.0;

  float _heading = 0;
  float _turning = 90;
  float _turnTo  = 0;

  Vector _lockedBulletDir;
  Vector _lastDir;

  //  Timed ship states
  float _invulnerable = 0;
  public float fastFire = 0;
  float _slowFire = 0;
  float _speedup = 0;

  //  Powerups XXX unused, hardcoded for now
  const int doubleFire  = 1;
  const int wideFire    = 2;
  // const int angleFire   = 3;
  const int reverseFire = 3;
  const int wideFire2   = 5;

  int _weaponLevel;

  const int FRAME_COUNT = 50;

  Vector _bright;
  Vector _dark;

  bit _shimmer = 0;

  Matrix _shootLeft;
  Matrix _shootRight;

  public Vector pos() { return _pos; }

  public this(NullGameManager gm, Field field)
  {
    _pad = gm.pad;    
    _mouse = gm.mouse;
    _screen = gm.screen;
    _gm = gm;

    _bulletSystem = new BulletSystem(gm, 100);
    _field = field;

    _bright = Vector.create(1.0, 0.98, 0.01, 1.0);
    _dark = Vector.create(1.0, 0.4, 0.09, 0.3);  
    _shootLeft = Matrix.rotationZ(PI / 60.0);
    _shootRight = Matrix.rotationZ(-PI / 60.0);
  }

  public void init()
  {
    _vb_ship = createShip();
    _boundingCircle = BoundingCircle.create(0.5, _pos, _pos);
    _bulletSystem.init(Vector.create(0.9, 1.0, 0.28, 1.0));
    _texture = _gm.textures["ship"];
    reset();
  }

  public void reset()
  {
    wickets = 3;
    _weaponLevel = 0;
    _pos = Vector.zero();
    _boundingCircle.pos = _pos;
    _boundingCircle.prev = _pos;
    _lockedBulletDir = Vector.create(0, 1.0, 0);
    _lastDir = _lockedBulletDir;
  }

  public void move(float elapsed)
  {
    static float bulletElapsed = 0;

    static float animElapsed = 0;
    static int i_frame = 0;

    updateTimedStates(elapsed);

    TwinStickPadState padInput = _pad.getState();
    MouseState mouseInput = _mouse.getState();

    Vector v = Vector.create(padInput.left.x, padInput.left.y);
    auto magSq = v.x * v.x + v.y * v.y;
    _stretch = 1.0;

    if (!(mouseInput.button & MouseState.Button.LEFT))
      _lockedBulletDir = Vector.zero;

    Vector bv;
    if (magSq > 0.1f && !(mouseInput.button & MouseState.Button.LEFT))
    {
      _stretch = 1.0 + (magSq * 0.30f);
      _turnTo = rad2deg(heading(v.x, v.y));
      bv = v;
      _lastDir = v;
    }
    else
    {
      bv = _lastDir;
    }

    _boundingCircle.prev = _pos;

    v *= shipSpeed;
    _pos.x += v.x;
    _pos.y += v.y;
    // Logger.instance.message(format("Position: %s", _pos.toString));
    _field.clampToField(_pos);

    _boundingCircle.pos = _pos;

    // animElapsed += elapsed;
    // if (animElapsed > 0.04f)
    // {
    //   _triangle.writeBatch(GL_TRIANGLES, _triangleSet[i_frame]);
    //   i_frame = (i_frame+1) % FRAME_COUNT;
    //   animElapsed = 0;
    // }

    bulletElapsed += elapsed;

    if ((padInput.right.lengthSq) > 0.1)
    {
      _lastDir = padInput.right;
      bv = Vector.create(padInput.right.x, padInput.right.y);
    }

    bv = normalize(bv);
    if (bulletElapsed > bulletDelay)
    {
      SoundManager.playSe("shot");

      auto nbv = normalize(bv);
      bv = bulletSpeed * nbv;

      Vector right = Vector.create(-nbv.y, nbv.x);

      if (_weaponLevel <= 0)
        _bulletSystem.shoot(_pos, bv);
      else
      {
        _bulletSystem.shoot(pos + right * 0.2f, bv);
        _bulletSystem.shoot(pos - right * 0.2f, bv);

        if (_weaponLevel >= 2)
        {
          Vector vleft = _shootLeft * bv;
          Vector vright = _shootRight * bv;
          _bulletSystem.shoot(pos, vleft);
          _bulletSystem.shoot(pos, vright);
        }

        if (_weaponLevel >= 2)
        {
          _bulletSystem.shoot(pos, right  * bulletSpeed);
          _bulletSystem.shoot(pos, -right * bulletSpeed);
        }

        if (_weaponLevel >= 3)
           _bulletSystem.shoot(_pos, -bv);
      }

      if (_weaponLevel >= 4) bulletDelay = 0.7f * NORMAL_BULLET_DELAY; 
      else bulletDelay = NORMAL_BULLET_DELAY;

      bulletElapsed = 0;
    }

    _bulletSystem.move(elapsed);
  }

  void updateTimedStates(float elapsed)
  {
    _invulnerable -= elapsed;
    if (_invulnerable < 0.0)
      _invulnerable = 0.0;

    fastFire = max(0.0f, fastFire - elapsed);

    if (fastFire) bulletDelay = 0.5f * NORMAL_BULLET_DELAY; 
    else bulletDelay = NORMAL_BULLET_DELAY;
  }

  public void collidedWithEnemy()
  {
    if (_invulnerable <= 0.0)
    {
      //  take a wicket
      _gm.levelManager.explosion.addRadialExplosion(_pos, 20, 0.4, 1.0, _bright, _dark);
      SoundManager.playSe("siren");
      if (--wickets == 0)
      {
        Logger.instance.message("Game over!");
        _gm.levelManager.endGame();
        return;
      }
      _invulnerable = INVULNERABLE_TIME;
    }
  }

  //  Calculate the rotation to move between headings
  float calcRotation(float src, float dst)
  in
  {
    assert(src >= 0 && src < 360);
    assert(dst >= 0 && dst < 360);
  }
  out (heading)
  {
    assert(std.math.abs(heading) <= 180);
  }
  body
  {
    if (src == dst)
      return 0;

    float ang1 = dst - src;
    if (std.math.abs(ang1) < 180)
      return ang1;

    if (ang1 < 0) ang1 += 360;
    else if (ang1 > 0) ang1 -= 360;

    return ang1;
  }
  
  public void draw()
  {
    drawShip();
    _bulletSystem.draw();
  }

  void drawShip()
  {
    _shimmer = !_shimmer;

    if (_shimmer && _invulnerable > 0.0)
      return;

    _texture.bind();
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    _screen.glTranslate(_pos);
    glRotatef(_turnTo, 0, 0, -1.0);

    if (_invulnerable > 0.0)
      glScalef(1.4, 1.4 * _stretch, 0);
    else
      glScalef(1.0, _stretch, 0);

    _vb_ship.drawBatch();

    _gm.feedbackBuffer.bind();
    _gm.feedbackBuffer.setPerspective();
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    _vb_ship.drawBatch();
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    _gm.feedbackBuffer.unbind();
    _screen.setPerspective();

    glPopMatrix();
    _texture.unbind();
  }

  private VertexBuffer!(Vertex) createShip()
  in
  {
    assert(_gm.shaper);
  }
  body
  {
    Vertex[6] vertexList;
    auto attr = ShapeAttr.create(Vector.zero, Vector.create(.6, 0.95, 1.0, 1.0), 1.0);
    _gm.shaper.writeBillboard(vertexList, 0, attr);
    //  Modify vertex colors
    Vertex.setColor(vertexList[1], 0.3, 0.85, 0.98);
    Vertex.setColor(vertexList[2], 0.2, 0.75, 0.98);

    auto vb = new VertexBuffer!(Vertex)(6);
    vb.writeBatch(GL_TRIANGLES, vertexList);
    return vb;
  }

  public void powerup(int p)
  {
    if (p == WEAPON)
      _weaponLevel = min(_weaponLevel+1, wideFire2);
    else if (p == HEALTH)
      wickets++;
  }
}

