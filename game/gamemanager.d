module game.gamemanager;

import core.rand;
import core.logger;

import derelict.opengl.gl;
import derelict.sdl.sdl;

import de.config;
import de.gamemanager;
import de.sound;
import de.texture;
import de.feedback;
import de.math;
import de.shader;
import de.resourcecache;

import game.levelmanager;
import game.titlemanager;
// import game.testmanager;

class NullGameManager : GameManager
{
  public enum GameState
  {
    TITLE = 0,
    PLAYING,
    TEST
  };

  TitleManager _titleManager;
  LevelManager _levelManager;
  public LevelManager levelManager() { return _levelManager; }
  // TestManager _testManager;

  FeedbackBuffer _fb;
  public FeedbackBuffer feedbackBuffer() { return _fb; }
  uint _frame = 0;

  private GameState state;

  public this(char[][] args)
  {
    super();

  }

  public void startPlaying()
  {
    _levelManager.reset();
    state = GameState.PLAYING;
    SoundManager.playBgm("zero");
  }

  public void stopPlaying(bool playMusic = true)
  {
    state = GameState.TITLE;
    if (playMusic)
      SoundManager.playBgm("title");
  }

  public void postInit()
  {
    //  Create feedback buffer
    Logger.instance.message("Creating feedback buffer");
    _fb = new FeedbackBuffer(_config.quadsize, screen);

    //  Load all resources
    loadSounds();
    loadTextures();
    loadShaders();

    _titleManager = new TitleManager();
    _titleManager.init(this);

    _levelManager = new LevelManager();
    _levelManager.init(this);

    // _testManager = new TestManager();
    // _testManager.init(this);

    if (_config.title)
      stopPlaying(false);
    else
      startPlaying();
  }

  private void loadSounds()
  {
    waves["shot"]  = Wave.create("waves/shot.wav", 0);
    SoundMixer.channelVolume(0, 0.4);
    waves["thunk"] = Wave.create("waves/low thunk stereo.wav", 1);
    waves["siren"] = Wave.create("waves/siren stereo.wav", 2);
    waves["destroyed"] = Wave.create("waves/destroyed.wav", 3);
    SoundMixer.channelVolume(3, 0.2);
    waves["levelup"] = Wave.create("waves/notify stereo.wav", 4);
    waves["expanding"] = Wave.create("waves/expanding.wav", 0);
    waves["boom"] = Wave.create("waves/boom.wav", 5);
    waves["spark"] = Wave.create("waves/spark.wav", 6);

    music["zero"] = Music.create("music/zero.mp3");
    music["title"] = Music.create("music/title.ogg");

    SoundManager.init(waves, music);
  }

  private void loadTextures()
  {
    textures["font"] = new Texture("../images/font_512.png");
    textures["particle"] = new Texture("../images/particle.png");
    textures["particle2"] = new Texture("../images/particle2.png");
    textures["logo"] = new Texture("../images/logo.png");
    textures["bullet"] = new Texture("../images/bullet.png");
    textures["ship"] = new Texture("../images/ship.png");
    textures["eye"] = new Texture("../images/eye.png");
    textures["flash"] = new Texture("../images/flash.png");
    textures["powerup"] = new Texture("../images/powerup.png");
    textures["arrow"] = new Texture("../images/arrow.png");
    textures["random"] = new Texture("../images/random.png");
    textures["shell"] = new Texture("../images/shell.png");
    textures["storm"] = new Texture("../images/storm.png");
  }

  //  Load and initialize shaders
  private void loadShaders()
  {
    auto textureShader = new TextureShader();
    textureShader.bind();
    textureShader["Color"] = Vector.create(0.9, 0.9, 0.9, 0.2);
    textureShader.unbind();
    shaders["texture"] = textureShader;

    auto blurShader = new BlurShader();
    blurShader.bind();
    blurShader["Persistence"] = _config.persistence;
    blurShader.unbind();
    shaders["blur"] = blurShader;
  }

  public void move(float elapsed)
  {
    trackFPS(elapsed);
    handleExitKeys();

    if (state == GameState.TITLE)
      _titleManager.move(elapsed);
    else if (state == GameState.PLAYING)
      _levelManager.move(elapsed);
    // else if (state == GameState.TEST)
    //   _testManager.move(elapsed); 
    SoundManager.playMarkedSe();
  }

  public void draw()
  in
  {
    assert(screen.surface !is null);
  }
  body
  {
    ++_frame;
    if (state == GameState.TITLE)
      _titleManager.draw();
    else if (state == GameState.PLAYING)
      _levelManager.draw();

    // else if (state == GameState.TEST)
    //   _testManager.draw();
  }
}

