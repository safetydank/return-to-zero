module game.levels.test;

import std.string;

import de.math;
import de.collision;
import de.vertex;
import de.vertexbuffer;
import de.shaper;

import game.bulletsystem;
import game.gamemanager;
import game.levelmanager;
import game.swarm.swarm;
import game.swarm.balloon;
import game.swarm.dumb;
import game.swarm.powerup;
import game.levels.level;

class TestLevel : Level
{
  BalloonSwarm _swarm;

  public this(NullGameManager gm)
  {
    super(gm, "da test level");
  }

  public void init()
  {
    _log.message("Create swarm");
    _swarm = new BalloonSwarm(_gm, 20);

    _clEnemies ~= _swarm;
    _clEnemyBullets ~= _lm.bullets[0];
  }

  public void reset()
  {
    super.reset();

    _log.message("Reset Level 1");

    _swarm.deactivate();
    _swarm.init(_lm.vbDyn[0], _gm.textures["particle"], _lm.bullets[0]);
    for (int i=0; i < 20; ++i)
    {
      _swarm.addBalloon(_lm.rndEnemyPosition, _lm.rndVectorXY(-0.1f, 0.1f), 1.0);
    }

    _lm.powerup.addPowerup(Vector.create(5,5), HEALTH, 20);

    _complete = false;
  }

  public void move(float elapsed)
  {
    super.move(elapsed);

    _swarm.move(elapsed);

    checkCollisions();

    //  Check level ending conditions
    if (_swarm.c_active == 0)
    {
      _log.message("swarm inactive: L1 complete");
      _complete = true;
    }
  }
}
