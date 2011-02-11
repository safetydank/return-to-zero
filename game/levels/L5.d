module game.levels.l5;

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

class L5 : Level
{
  MultiSwarm _multi;
  CascadeSwarm _cascade;

  public this(NullGameManager gm)
  {
    super(gm, "5 - keep on trucking");
  }

  public void init()
  {
    _multi   = _lm.multiSwarms[0];
    _cascade = _lm.cascadeSwarms[0];

    _clEnemies ~= _multi;
    _clEnemies ~= _cascade;
    _clEnemyBullets = null;
  }

  public void reset()
  {
    super.reset();

    _multi.deactivate();
    _cascade.deactivate();

    _multi.init(_lm.vbDyn[0], _gm.textures["shell"], Vector.create(1.0, 0.23, 0.25, 0.8));
    _cascade.init(_lm.vbDyn[1], _gm.textures["random"], Vector.create(0.9f, 0.95f, 1.0, 1.0), 0.6, 2.5);
    _lm.powerup.addPowerup(Vector.create(-6,6), WEAPON, 60);
    _lm.powerup.addPowerup(Vector.create(7,1), HEALTH, 60);

    for (int i=0; i < 10; ++i)
    {
      _multi.addMulti(_lm.rndEnemyPosition, _lm.rndVectorXY(0.2f), 2.0, 10, 0.8);
    }

    _lm.field.setEffects(OceanBlueRandom());
    _complete = false;
  }

  public void move(float elapsed)
  {
    super.move(elapsed);

    static float _cascadeTime = 0;
    _cascadeTime += elapsed;
    if (_cascadeTime > 6.0)
    {
       _cascadeTime = 0; 
       _cascade.start(10, true);
    }

    _multi.move(elapsed);
    _cascade.move(elapsed);

    checkCollisions();

    //  Check level ending conditions
    if (_multi.c_active == 0)
    {
      _log.message("swarms inactive: L5 complete");
      _complete = true;
    }
  }
}
