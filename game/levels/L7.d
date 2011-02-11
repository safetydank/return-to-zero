module game.levels.l7;

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
import game.swarm.cascade;
import game.swarm.balloon;
import game.levels.level;
import game.effects;

class L7 : Level
{
  CascadeSwarm _cascadeTop;
  CascadeSwarm _cascadeBottom;
  BalloonSwarm _swarm;

  public this(NullGameManager gm)
  {
    super(gm, "7 - the valley");
  }

  public void init()
  {
    _cascadeTop = _lm.cascadeSwarms[0];
    _cascadeBottom = _lm.cascadeSwarms[1];
    _swarm = new BalloonSwarm(_gm, 30);

    _clEnemies ~= _cascadeTop;
    _clEnemies ~= _cascadeBottom;
    _clEnemies ~= _swarm;
    _clEnemyBullets ~= _lm.bullets[0];
  }

  public void reset()
  {
    super.reset();

    _cascadeTop.deactivate();
    _cascadeBottom.deactivate();
    _swarm.deactivate();

    _cascadeTop.init(_lm.vbDyn[0], _gm.textures["random"], Vector.create(0.9f, 0.95f, 1.0, 1.0), 0.9, 2.5);
    _cascadeBottom.init(_lm.vbDyn[1], _gm.textures["random"], Vector.create(0.9f, 0.95f, 1.0, 1.0), 0.9, 2.5);

    _swarm.init(_lm.vbDyn[2], _gm.textures["storm"], _lm.bullets[0]);
    _lm.powerup.addPowerup(Vector.create(5,-7), WEAPON, 60);
    _lm.powerup.addPowerup(Vector.create(8,-3), HEALTH, 60);

    for (int i=0; i < 25; ++i)
    {
      _swarm.addBalloon(_lm.rndEnemyPosition, _lm.rndVectorXY(-0.1f, 0.1f), 1.0);
    }

    _lm.field.setEffects(GreenRandom());
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
       _cascadeTop.start(10, true);
       _cascadeBottom.start(10, false);
    }

    _cascadeTop.move(elapsed);
    _cascadeBottom.move(elapsed);
    _swarm.move(elapsed);

    checkCollisions();

    //  Check level ending conditions
    if (_swarm.c_active == 0)
    {
      _complete = true;
    }
  }
}
