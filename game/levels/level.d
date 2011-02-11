module game.levels.level;

import core.logger;
import core.rand;
import core.interpolate;

import de.math;
import de.collision;
import de.sound;

import game.ship;
import game.gamemanager;
import game.levelmanager;

import game.swarm.swarm;
import game.swarm.powerup;
import game.bulletsystem;

protected import derelict.opengl.gl;

//  Base level class
class Level
{
  Logger _log;
  Rand _rand;
  NullGameManager _gm;
  LevelManager _lm;

  protected bool _complete;
  public bool complete() { return _complete; }

  char[] _name;
  public char[] name() { return _name; }

  float _SIZE;
  float _clock;

  //  Collision groups
  protected Swarm[] _clEnemies;
  protected BulletSystem[] _clEnemyBullets;

  public this(NullGameManager gm, char[] name)
  {
    _log = Logger.instance;
    _gm = gm;
    _lm = gm.levelManager;
    _name = name;
    _rand = new Rand();
    _SIZE = _gm.screen.height / 32.0;

    _complete = false;
  }

  public abstract void init();

  public void reset()
  {
    _lm.renderString(_name);
    _clock = 0;
    _lm.powerup.deactivate();
  }

  public void move(float elapsed)
  {
    _clock += elapsed;

    _lm.score.move(elapsed);
    _lm.field.move(elapsed);
    _lm.ship.move(elapsed);
    _lm.explosion.move(elapsed);
    _lm.flash.move(elapsed);
    _lm.powerup.move(elapsed);

    if (_clEnemyBullets !is null)
    {
      foreach (bs; _clEnemyBullets)
      {
        bs.move(elapsed);
      }
    }

    auto cameraPos = ((_lm.ship.pos - _lm.camera.pos) * 0.010) + _lm.camera.pos;
    cameraPos.z = 20.0;
    _lm.field.clampToEye(cameraPos);
    _lm.camera.pos = Vector.create(cameraPos.x, cameraPos.y, cameraPos.z);
  }

  public void draw()
  {
    drawLevelName();
    drawField();
    setPerspectiveCamera();
    drawShip();

    //  draw enemy swarms
    if (_clEnemies !is null)
    {
      foreach (swarm; _clEnemies)
        swarm.draw();
    }
    //  draw bullet systems
    if (_clEnemyBullets !is null)
    {
      foreach (bullet; _clEnemyBullets)
        bullet.draw();
    }

    _lm.explosion.draw();
    _lm.flash.draw();
    _lm.powerup.draw();
    drawScore();
  }

  protected void setPerspectiveCamera()
  {
    _gm.screen.setPerspective();
    _lm.camera.pos.z = _lm.field.EYE_POS_Z;
    _lm.camera.setView();
  }

  protected void drawField()
  {
    _lm.field.draw();
  }

  protected void drawShip()
  {
    _lm.ship.draw();
  }

  protected void checkCollisions()
  {
    // Check for player bullet / enemy collisions
    if (_clEnemies !is null)
    {
      checkPlayerBulletCollisions();
      checkPlayerEnemyCollisions();
    }

    // if (_clStatic !is null)
    checkPlayerStaticCollision();

    if (_clEnemyBullets !is null)
      checkEnemyBulletCollisions();
  }

  private void checkPlayerBulletCollisions()
  {
    foreach (Bullet b; _lm.ship.bulletSystem.bullets)
    {
      foreach (swarm; _clEnemies)
      {
        bool hit = false;
        foreach (enemy; swarm.bodies)
        {
          if (collided(b.boundingCircle, enemy.boundingCircle))
          {
            b.hit();
            swarm.hit(enemy, b.vel);
            hit = true;
            break;
          }
        }
        if (hit) break;
      }
    }
  }

  private void checkPlayerEnemyCollisions()
  {
    Ship ship = _lm.ship;

    foreach (swarm; _clEnemies)
    {
      foreach (enemy; swarm.bodies)
      {
        if (collided(ship.boundingCircle, enemy.boundingCircle))
        {
          // XXX something happens to the enemy?
          ship.collidedWithEnemy();
          swarm.collidedWithPlayer(enemy);
        }
      }
    }
  }

  private void checkPlayerStaticCollision()
  {
    Ship ship = _lm.ship;

    foreach (p; _lm.powerup.bodies)
    {
      if (p.powerup != COLLECTED && collided(ship.boundingCircle, p.boundingCircle, true))
      {
        ship.powerup(p.powerup);
        SoundManager.playSe("thunk");
        p.type = p.powerup;
        p.powerup = COLLECTED;
        p.t = 0;
        p.lifetime = 1.0;
      }
    }
  }

  private void checkEnemyBulletCollisions()
  {
    Ship ship = _lm.ship;

    foreach (BulletSystem bs; _clEnemyBullets)
    {
      foreach (b; bs.bullets)
      {
        if (collided(ship.boundingCircle, b.boundingCircle, true))
        {
          ship.collidedWithEnemy();
        }
      }
    }
  }

  protected void drawScore()
  {
    _gm.screen.setViewport();
    _gm.screen.setOrtho();
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glTranslatef(0, _gm.screen.height - _SIZE * 1.5f, 0);
    glScalef(_SIZE, _SIZE, 0);
    _lm.score.draw();
    glPopMatrix();
  }

  protected void drawLevelName()
  {
    if (_clock < 0.5)
    {
      _lm.drawString(_clock * 2.0, true);
    }

    if (_clock < 5.0)
    {
      float alpha = (_clock * 0.5f) / 1.5f;
      _lm.drawString(1.0, false, linear_interp(0.5f, 0.0f, alpha));
    }
  }
}

