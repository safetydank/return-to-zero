module game.levels.l4;

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
import game.swarm.multi;
import game.swarm.powerup;
import game.levels.level;
import game.effects;

class L4 : Level
{
  DumbSwarm  _swarm;
  DumbSwarm  _swarm2;
  MultiSwarm _multi;

  public this(NullGameManager gm)
  {
    super(gm, "4 - she sells");
  }

  public void init()
  {
    _log.message("Create swarm");
    _swarm  = _lm.dumbSwarms[0];
    _swarm2 = _lm.dumbSwarms[1];
    _multi  = _lm.multiSwarms[0];

    _clEnemies ~= _swarm;
    _clEnemies ~= _swarm2;
    _clEnemies ~= _multi;
    _clEnemyBullets = null;
  }

  public void reset()
  {
    super.reset();

    _swarm.deactivate();
    _swarm2.deactivate();
    _multi.deactivate();

    _swarm.init(_lm.vbDyn[0], _gm.textures["eye"], 0.5);
    _swarm2.init(_lm.vbDyn[1], _gm.textures["arrow"], 0.4);
    _multi.init(_lm.vbDyn[2], _gm.textures["shell"], Vector.create(1.0, 0.23, 0.25, 0.8));
    _lm.powerup.addPowerup(Vector.create(-7,-10), WEAPON, 60);

    for (int i=0; i < 5; ++i)
    {
      _swarm.addEnemy(_lm.rndEnemyPosition, 0.04);
    }

    for (int i=0; i < 10; ++i)
    {
      _swarm2.addEnemy(_lm.rndEnemyPosition, 0.06);
    }

    for (int i=0; i < 8; ++i)
    {
      _multi.addMulti(_lm.rndEnemyPosition, _lm.rndVectorXY(0.2f), 2.0, 10, 0.8);
    }

    _lm.field.setEffects(GreenRandom());
    _complete = false;
  }

  public void move(float elapsed)
  {
    super.move(elapsed);

    _swarm.move(elapsed);
    _swarm2.move(elapsed);
    _multi.move(elapsed);

    checkCollisions();

    //  Check level ending conditions
    if (_swarm.c_active == 0 && _swarm2.c_active == 0 && _multi.c_active == 0)
    {
      _log.message("swarms inactive: L2 complete");
      _complete = true;
    }
  }
}
