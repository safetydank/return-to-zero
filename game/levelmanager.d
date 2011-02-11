module game.levelmanager; 

import core.rand;
import core.logger;

import de.math;
import de.config;
import de.camera;
import de.screen;
import de.sound;
import de.texture;
import de.text;
import de.vertex;
import de.vertexbuffer;
import de.shaper;
import de.vertexset;
import de.resourcecache;

import derelict.opengl.gl;

import game.gamemanager;
import game.bulletsystem;
import game.effects;
import game.ship;
import game.field;
import game.score;
import game.swarm.explosion;
import game.swarm.flash;
import game.swarm.powerup;
import game.swarm.dumb;
import game.swarm.multi;
import game.swarm.cascade;

import game.levels.level;
import game.levels.l1;
import game.levels.l2;
import game.levels.l3;
import game.levels.l4;
import game.levels.l5;
import game.levels.l6;
import game.levels.l7;
import game.levels.l8;
import game.levels.l9;
import game.levels.test;

class LevelManager
{
  const int DYNAMIC_VB_SIZE = 4000;

  Logger _log;
  Config _config;

  NullGameManager _gm;
  Level[] _levels;
  int _i_level = 0;

  bool  gameOver = false;
  float gameOverElapsed = 0;
  const float GAME_OVER_TIME = 8.0;

  //  Game objects
  Ship _ship;
  public Ship ship() { return _ship; }

  Field _field;
  public Field field() { return _field; }

  Camera _camera;
  public Camera camera() { return _camera; }

  Score _score;
  public Score score() { return _score; }

  BulletSystem[4] _bullets;
  public BulletSystem[] bullets() { return _bullets; }

  //  Common resources

  //  Dynamic vertex buffers for use by swarms
  VertexBuffer!(Vertex)[8] _vbDyn;
  public VertexBuffer!(Vertex)[] vbDyn() { return _vbDyn; }

  //  Explosion, flash and powerup renderer
  ExplosionSwarm _explosion;
  public ExplosionSwarm explosion() { return _explosion; }
  VertexBuffer!(Vertex) _vbExplosion;

  FlashSwarm _flash;
  public FlashSwarm flash() { return _flash; }
  VertexBuffer!(Vertex) _vbFlashes;

  PowerupSwarm _powerup;
  public PowerupSwarm powerup() { return _powerup; }

  //  Enemy swarms
  DumbSwarm[5] _dumbSwarms;
  public DumbSwarm[] dumbSwarms() { return _dumbSwarms; }

  MultiSwarm[5] _multiSwarms;
  public MultiSwarm[] multiSwarms() { return _multiSwarms; }

  CascadeSwarm[5] _cascadeSwarms;
  public CascadeSwarm[] cascadeSwarms() { return _cascadeSwarms; }

  Rand _rand;

  //  For drawing the level name
  Texture _fontTexture;
  TextLineRenderer _textRenderer;
  VertexBuffer!(BasicVertex) _text;
  float _textSize;

  bool _init = false;

  //  Precalculated rotational vertex sets
  VertexSet _rotSquare;
  public VertexSet rotSquare() { return _rotSquare; };

  public this()
  {
    _log = Logger.instance;
    _config = Config.instance;
  }

  public void init(NullGameManager gm)
  in
  {
    assert(gm);
  }
  body
  {
    _rand = new Rand();
    _gm = gm;

    createGameObjects();
    createRotationSets();

    _fontTexture = _gm.textures["font"];
    _text = TextLineRenderer.createTextBuffer();
    _textRenderer = new TextLineRenderer(_fontTexture, 16);
    _textRenderer.charWidth = 1.4f;
    _textSize = _gm.screen.height / 64.0f;

    foreach (inout vb; _vbDyn)
      vb = new VertexBuffer!(Vertex)(DYNAMIC_VB_SIZE);

    foreach (inout bs; _bullets)
    {
      bs = new BulletSystem(_gm, 300);
      bs.init(Vector.create(1.0, 0.3, 0.3, 1.0));
    }

    foreach (inout ds; _dumbSwarms)
      ds = new DumbSwarm(_gm, 60);

    foreach (inout ms; _multiSwarms)
      ms = new MultiSwarm(_gm, 100);

    foreach (inout cs; _cascadeSwarms)
      cs = new CascadeSwarm(_gm, 30);

    _explosion = new ExplosionSwarm(_gm, 600);
    _vbExplosion = new VertexBuffer!(Vertex)(DYNAMIC_VB_SIZE);
    _explosion.init(_vbExplosion, _gm.textures["particle2"]);

    _flash = new FlashSwarm(_gm, 600);
    _vbFlashes = new VertexBuffer!(Vertex)(DYNAMIC_VB_SIZE);
    _flash.init(_vbFlashes, _gm.textures["flash"]);

    _powerup = new PowerupSwarm(_gm, 100);
    _powerup.init(_gm.textures["powerup"]);

    createLevels();
    foreach (l; _levels) { l.init(); }

    reset();
    _init = true;
  }

  public void reset()
  {
    ship.reset();
    if (_config.level == -1)
      _i_level = _levels.length - 1;
    else
      _i_level = (abs(_config.level - 1)) % _levels.length;
    resetLevel();
    _score.reset();
    gameOver = false;
    gameOverElapsed = 0;
  }

  public void resetLevel()
  {
    if (_init)
    {
      SoundManager.playSe("levelup");
    }
    level.reset();
  }

  public void nextLevel()
  {
    _log.message(format("nextLevel: current i_level %d levels length %d", _i_level, _levels.length));
    ++_i_level;
    _log.message(format("after inc: nextLevel: current i_level %d levels length %d", _i_level, _levels.length));
    if (_i_level >= _levels.length)
    {
      _log.message(format("Changing to level %d", _i_level));
      _i_level = 0;
    }
  }

  void renderString(char[] name)
  {
    _textRenderer.renderString(name, _text);
  }

  public void endGame()
  {
    _gm.levelManager.renderString("Game over");
    gameOver = true;
    gameOverElapsed = GAME_OVER_TIME;
    field.setEffects(GameOver());
    SoundManager.fadeBgm();
  }

  void drawString(float mu, bool toFeedback = false, float alpha = 0.5f)
  {
    float width, height;

    float scalex = (0.6 + mu) * _textSize;
    float scaley = scalex;

    if (toFeedback)
    {
      _gm.feedbackBuffer.bind();
      width = _gm.feedbackBuffer.width;
      height = _gm.feedbackBuffer.height;
      scalex *= 1.05f;
      scaley *= 1.4f;
    }
    else
    {
      width = _gm.screen.width;
      height = _gm.screen.height;
    }

    _gm.screen.setViewport();
    _gm.screen.setOrtho();
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    float cx = (width * 0.5f) - (_textSize * level.name.length);
    float cy = (height * 0.5f) - (_textSize * 0.8f);
    glTranslatef(cx, cy, 0);

    glScalef(scalex, scaley, 0);

    _textRenderer.bind();
    glColor4f(1.0, 0.8, 0.8, alpha);
    _text.drawBatch();
    _textRenderer.unbind();
    glPopMatrix();

    if (toFeedback)
    {
      _gm.feedbackBuffer.unbind();
    }

    glColor4f(1.0, 1.0, 1.0, 1.0);
  }

  void createGameObjects()
  {
    _log.message("LM: Create field");
    _field = new Field(_gm);
    _field.init();
    _field.setShip(_ship);

    _log.message("LM: Create ship");
    _ship = new Ship(_gm, _field);
    _ship.init();

    _log.message("LM: Create field");
    _camera = new Camera(Vector.create(0,0,20), Vector.create(0,0,0),
        Vector.create(0,1,0));

    _log.message("LM: Create score");
    _score = new Score(_gm.textures["font"], _ship);
  }

  void createRotationSets()
  {
    Vertex[6] vertexList;
    _rotSquare = new VertexSet();
    for (int i=0; i <= 360; ++i)
    {
      auto attr = ShapeAttr.create(Vector.zero, Vector.create(1., 1., 1., 1.), 1.0);
      attr.rotation = Matrix.rotationZ(cast(float) -i * 2 * PI / 360);
      _gm.shaper.writeBillboard(vertexList, 0, attr);

      //  Add to set
      _rotSquare[i] = vertexList;
    }
  }

  void createLevels()
  {
    // _levels ~= new TestLevel(_gm);
    _levels ~= new L1(_gm);
    _levels ~= new L2(_gm);
    _levels ~= new L3(_gm);
    _levels ~= new L4(_gm);
    _levels ~= new L5(_gm);
    _levels ~= new L6(_gm);
    _levels ~= new L7(_gm);
    _levels ~= new L8(_gm);
    _levels ~= new L9(_gm);
  }

  private Level level() 
  in { assert(_levels[_i_level]); }
  body { return _levels[_i_level]; }

  public void move(float elapsed)
  {
    if (gameOver)
    {
      gameOverElapsed -= elapsed;
      field.move(elapsed);
      score.move(elapsed);
      if (gameOverElapsed < 0)
      {
        _gm.stopPlaying();
      }
    }
    else
    {
      level.move(elapsed);
      if (level.complete == true)
      {
        nextLevel();
        resetLevel();
      }
    }
  }

  public void draw()
  {
    _gm.screen.beginScene();
    if (gameOver)
    {
      field.draw();
      score.draw();
      drawString(1.0, false, 1.0);
    }
    else
    {
      level.draw();
    }
    _gm.screen.endScene();
  }

  public Vector rndVectorXY(float f)
  {
    return Vector.create(_rand.nextFloat(f), _rand.nextFloat(f));
  }

  public Vector rndVectorXY(float min, float max)
  {
    float x = _rand.nextFloat(min, max);
    float y = _rand.nextFloat(min, max);
    return Vector.create(x, y);
  }

  public Vector rndEnemyPosition()
  {
    Vector ep = rndVectorXY(-20.0, 20.0);
    if (ep.lengthSq < 256.0)
      ep = normalize(ep) * 16.0;
    ep += ship.pos;
    field.clampToField(ep);

    return ep;
  }

}

