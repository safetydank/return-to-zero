module game.levels.l6;

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
import game.swarm.cascade;
import game.levels.level;
import game.effects;

class L6 : Level
{
  MultiSwarm _multi;
  DumbSwarm _dswarm1;
  DumbSwarm _dswarm2;
  CascadeSwarm _cascade;

  public this(NullGameManager gm)
  {
    super(gm, "6 - mad rush");
  }

  public void init()
  {
    _multi   = _lm.multiSwarms[0];
    _cascade = _lm.cascadeSwarms[0];
    _dswarm1 = _lm.dumbSwarms[0];
    _dswarm2 = _lm.dumbSwarms[1];

    _clEnemies ~= _multi;
    _clEnemies ~= _cascade;
    _clEnemies ~= _dswarm1;
    _clEnemies ~= _dswarm2;
    _clEnemyBullets = null;
  }

  public void reset()
  {
    super.reset();

    _multi.deactivate();
    _cascade.deactivate();

    _multi.init(_lm.vbDyn[0], _gm.textures["shell"], Vector.create(1.0, 0.63, 0.25, 0.8));
    _cascade.init(_lm.vbDyn[1], _gm.textures["random"], Vector.create(0.9f, 0.95f, 1.0, 1.0), 0.9, 2.5);
    _dswarm1.init(_lm.vbDyn[2], _gm.textures["eye"], 0.5);
    _dswarm2.init(_lm.vbDyn[3], _gm.textures["arrow"], 0.5);
    _lm.powerup.addPowerup(Vector.create(-8,-10), WEAPON, 60);

    for (int i=0; i < 10; ++i)
    {
      _dswarm1.addEnemy(_lm.rndEnemyPosition, 0.02);
    }

    for (int i=0; i < 10; ++i)
    {
      _dswarm2.addEnemy(_lm.rndEnemyPosition, 0.05);
    }

    for (int i=0; i < 4; ++i)
    {
      _multi.addMulti(_lm.rndEnemyPosition, _lm.rndVectorXY(0.2f), 2.0, 10, 0.8);
    }

    _lm.field.setEffects(SwirlyRedLines());
    _complete = false;
  }

  public void move(float elapsed)
  {
    super.move(elapsed);

    static float _cascadeTime = 0;
    _cascadeTime += elapsed;
    if (_cascadeTime > 4.0)
    {
       _cascadeTime = 0; 
       _cascade.start(10, false);
    }

    _multi.move(elapsed);
    _cascade.move(elapsed);
    _dswarm1.move(elapsed);
    _dswarm2.move(elapsed);

    checkCollisions();

    //  Check level ending conditions
    if (_multi.c_active == 0 && _dswarm1.c_active == 0 && _dswarm2.c_active == 0)
    {
      _log.message("swarms inactive: L5 complete");
      _complete = true;
    }
  }
}
