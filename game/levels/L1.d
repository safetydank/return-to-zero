module game.levels.l1;

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
import game.swarm.dumb;
import game.swarm.powerup;
import game.levels.level;
import game.effects;

class L1 : Level
{
  DumbSwarm _swarm;

  public this(NullGameManager gm)
  {
    super(gm, "1 - fat gold chains");
  }

  public void init()
  {
    _log.message("Create swarm");
    _swarm = _lm.dumbSwarms[0];

    _clEnemies ~= _swarm;
    _clEnemyBullets = null;
  }

  public void reset()
  {
    super.reset();

    _log.message("Reset Level 1");

    _swarm.deactivate();
    _swarm.init(_lm.vbDyn[0], _gm.textures["eye"], 0.5, Vector.create(1., 0.4, 0.4, 0.9));
    for (int i=0; i < 20; ++i)
    {
      _swarm.addEnemy(_lm.rndEnemyPosition, 0.02);
    }

    _lm.field.setEffects(MyFatGoldChains());
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
