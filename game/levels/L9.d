module game.levels.l9;

import std.string;

import de.math;
import de.collision;
import de.vertex;
import de.vertexbuffer;
import de.shaper;

import game.effects;
import game.bulletsystem;
import game.gamemanager;
import game.levelmanager;
import game.swarm.swarm;
import game.swarm.dumb;
import game.swarm.multi;
import game.swarm.cascade;
import game.swarm.powerup;
import game.swarm.balloon;
import game.levels.level;
import game.effects;

class L9 : Level
{
  DumbSwarm  _dumbSwarm;
  MultiSwarm _swarm;
  CascadeSwarm _cascade;
  CascadeSwarm _cascade2;
  BalloonSwarm _balloon;

  public this(NullGameManager gm)
  {
    super(gm, "9 - need to sleep!");
  }

  public void init()
  {
    _log.message("Create swarm");
    _swarm = _lm.multiSwarms[0];
    _dumbSwarm = _lm.dumbSwarms[0];
    _cascade = _lm.cascadeSwarms[0];
    _cascade2 = _lm.cascadeSwarms[1];
    _balloon = new BalloonSwarm(_gm, 30);

    _clEnemies ~= _swarm;
    _clEnemies ~= _dumbSwarm;
    _clEnemies ~= _cascade;
    _clEnemies ~= _cascade2;
    _clEnemies ~= _balloon;
    _clEnemyBullets = null;
  }

  public void reset()
  {
    super.reset();

    _swarm.init(_lm.vbDyn[0], _gm.textures["shell"], Vector.create(1.0, 0.23, 0.25, 0.8));
    _swarm.deactivate();
    _dumbSwarm.init(_lm.vbDyn[1], _gm.textures["eye"], 0.5, Vector.create(0.7, 1.0, 0.6, 0.8));
    _dumbSwarm.deactivate();
    _cascade.init(_lm.vbDyn[2], _gm.textures["random"], Vector.create(0.9f, 0.95f, 1.0, 1.0), 0.6, 0.35);
    _cascade.deactivate();
    _cascade2.init(_lm.vbDyn[3], _gm.textures["random"], Vector.create(0.9f, 0.95f, 1.0, 1.0), 0.6, 0.35);
    _cascade2.deactivate();
    _lm.powerup.addPowerup(Vector.create(-10, 10), HEALTH, 60);
    _balloon.init(_lm.vbDyn[4], _gm.textures["storm"], _lm.bullets[0]);
    _balloon.deactivate();

    for (int i=0; i < 20; ++i)
    {
      _swarm.addMulti(_lm.rndEnemyPosition, _lm.rndVectorXY(0.2f), 2.0, 10, 0.8);
    }

    for (int i=0; i < 20; ++i)
    {
      _balloon.addBalloon(_lm.rndEnemyPosition, _lm.rndVectorXY(-0.1f, 0.1f), 1.0);
    }

    for (int i=0; i < 40; ++i)
    {
      _dumbSwarm.addEnemy(_lm.rndEnemyPosition, 0.06);
    }

    for (int i=0; i < 40; ++i)
    {
      _dumbSwarm.addEnemy(_lm.rndEnemyPosition, 0.04);
    }


    _complete = false;
    _lm.field.setEffects(GreenPurpleMixed());
  }

  public void move(float elapsed)
  {
    static float _cascadeTime = 0;

    super.move(elapsed);

    _cascadeTime += elapsed;
    if (_cascadeTime > 5.0)
    {
       _cascadeTime = 0; 
       _cascade.start(10, false);
    }

    _swarm.move(elapsed);
    _dumbSwarm.move(elapsed);
    _cascade.move(elapsed);
    _cascade2.move(elapsed);
    _balloon.move(elapsed);
    checkCollisions();

    //  Check level ending conditions
    if (_swarm.c_active == 0 && _dumbSwarm.c_active == 0)
    {
      _log.message("swarm inactive: L2 complete");
      _complete = true;
    }
  }
}
