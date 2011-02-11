module game.levels.l8;

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
import game.swarm.powerup;
import game.swarm.cascade;
import game.swarm.cascade;
import game.swarm.balloon;
import game.levels.level;

class L8 : Level
{
  CascadeSwarm _cascadeTop;
  CascadeSwarm _cascadeBottom;
  BalloonSwarm _swarm;
  MultiSwarm _multi;

  public this(NullGameManager gm)
  {
    super(gm, "8 - turn to hate");
  }

  public void init()
  {
    _cascadeTop = _lm.cascadeSwarms[0];
    _cascadeBottom = _lm.cascadeSwarms[1];
    _swarm = new BalloonSwarm(_gm, 30);
    _multi = _lm.multiSwarms[0];

    _clEnemies ~= _cascadeTop;
    _clEnemies ~= _cascadeBottom;
    _clEnemies ~= _swarm;
    _clEnemies ~= _multi;
    _clEnemyBullets ~= _lm.bullets[0];
  }

  public void reset()
  {
    super.reset();

    _cascadeTop.deactivate();
    _cascadeBottom.deactivate();
    _swarm.deactivate();

    _cascadeTop.init(_lm.vbDyn[0], _gm.textures["random"], Vector.create(0.95, 0.9, 0.8, 1.0), 0.9, 2.5);
    _cascadeBottom.init(_lm.vbDyn[1], _gm.textures["random"], Vector.create(0.95, 0.9, 0.8, 1.0), 0.9, 2.5);

    _swarm.init(_lm.vbDyn[2], _gm.textures["storm"], _lm.bullets[0]);
    _lm.powerup.addPowerup(Vector.create(-3,-3), WEAPON, 60);
    _lm.powerup.addPowerup(Vector.create(3,3), HEALTH, 60);
    _multi.init(_lm.vbDyn[3], _gm.textures["shell"], Vector.create(1.0, 0.23, 0.25, 0.8));

    for (int i=0; i < 25; ++i)
    {
      _swarm.addBalloon(_lm.rndEnemyPosition, _lm.rndVectorXY(-0.1f, 0.1f), 1.0);
    }

    for (int i=0; i < 12; ++i)
    {
      _multi.addMulti(_lm.rndEnemyPosition, _lm.rndVectorXY(0.2f), 2.0, 10, 0.8);
    }

    _lm.field.setEffects(GreenPurpleMixed());
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
       _cascadeTop.start(20, true);
       _cascadeBottom.start(10, false);
    }

    _cascadeTop.move(elapsed);
    _cascadeBottom.move(elapsed);
    _swarm.move(elapsed);
    _multi.move(elapsed);

    checkCollisions();

    //  Check level ending conditions
    if (_swarm.c_active == 0 && _multi.c_active == 0)
    {
      _complete = true;
    }
  }
}
