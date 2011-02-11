module game.levels.l2;

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

class L2 : Level
{
  DumbSwarm _swarm;
  DumbSwarm _swarm2;

  public this(NullGameManager gm)
  {
    super(gm, "2 - the eyes of easy");
  }

  public void init()
  {
    _log.message("Create swarm");
    _swarm  = _lm.dumbSwarms[0];
    _swarm2 = _lm.dumbSwarms[1];

    _clEnemies ~= _swarm;
    _clEnemies ~= _swarm2;
    _clEnemyBullets = null;
  }

  public void reset()
  {
    super.reset();

    _log.message("Reset Level 2");

    _swarm.deactivate();
    _swarm2.deactivate();

    _swarm.init(_lm.vbDyn[0], _gm.textures["eye"], 0.5, Vector.create(0.3,0.7,0.9,0.7));
    _swarm2.init(_lm.vbDyn[1], _gm.textures["arrow"], 0.4, Vector.create(0.5,0.9,0.6,0.8));

    for (int i=0; i < 30; ++i)
    {
      _swarm.addEnemy(_lm.rndEnemyPosition, 0.04);
    }

    for (int i=0; i < 20; ++i)
    {
      _swarm2.addEnemy(_lm.rndEnemyPosition, 0.06);
    }

    _lm.field.setEffects(BlueSinCubePlusRose());
    _complete = false;
  }

  public void move(float elapsed)
  {
    super.move(elapsed);

    _swarm.move(elapsed);
    _swarm2.move(elapsed);

    checkCollisions();

    //  Check level ending conditions
    if (_swarm.c_active == 0 && _swarm2.c_active == 0)
    {
      _log.message("swarms inactive: L2 complete");
      _complete = true;
    }
  }
}
