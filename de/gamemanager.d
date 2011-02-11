module de.gamemanager;

import derelict.sdl.sdl;

import de.mainloop;
import de.screen;
import de.input;
import de.twinstickpad;
import de.config;
import de.script;
import de.math;
import de.sound;
import de.resourcecache;
import de.texture;
import de.shaper;
import de.shader;
import de.vertex;
import de.mouse;

import core.logger;
import core.rand;

//  Base game manager class
class GameManager
{
  public MainLoop mainLoop;  
  public Screen screen;
  public Input input;
  public SoundMixer soundMixer;
  public TwinStickPad pad;
  public Mouse mouse;

  Shaper!(Vertex) _shaper;
  public Shaper!(Vertex) shaper() { return _shaper; }

  public ResourceCache!(Texture) textures;
  public ResourceCache!(Wave)    waves;
  public ResourceCache!(Music)   music;
  public ResourceCache!(Shader)  shaders;

  bool _escPressed = false;

  protected Logger _log;
  protected Config _config;

  Interpreter _script;

  //  Track framerate
  int _c_frames  = 0;
  float _c_elapsed = 0;

  public abstract void postInit();
  public abstract void move(float elapsed);
  public abstract void draw();

  public this()
  {
    _log = Logger.instance;
    _config = Config.instance;
  }

  public void init()
  in
  {
    assert(screen);
  }
  body
  {
    screen.clearColor = Vector.create(0.0, 0.0, 0.0, 0.0);
    _script = new Interpreter();
    soundMixer = new SoundMixer();
    SoundMixer.init();

    textures = new ResourceCache!(Texture)();
    waves    = new ResourceCache!(Wave)();
    music    = new ResourceCache!(Music)();
    shaders  = new ResourceCache!(Shader)();

    _shaper = new Shaper!(Vertex)();

    postInit();
  }

  protected void trackFPS(float elapsed)
  {
    ++_c_frames;
    if (_c_elapsed > 5.0)
    {
      Logger.instance.message(format("Average FPS for last %f seconds: %f", _c_elapsed,
            cast(float) _c_frames / _c_elapsed ));
      _c_frames  = 0;
      _c_elapsed = 0;
    }

    _c_elapsed += elapsed;
  }

  protected void handleExitKeys()
  {
    //  exit immediately on alt-f4
    if (pad.keys[SDLK_F4] == SDL_PRESSED 
        && (pad.keys[SDLK_RALT] == SDL_PRESSED || pad.keys[SDLK_LALT] == SDL_PRESSED))
    {
      mainLoop.breakLoop();
    }
    else if (pad.keys[SDLK_ESCAPE] == SDL_PRESSED)
    {
      if (!_escPressed)
      {
        _escPressed = true;
        //  XXX check what state we're in before doing anything
        mainLoop.breakLoop();
      }
    }
    else if (pad.keys[SDLK_SPACE] == SDL_PRESSED)
    {
      // mainLoop.pause();
    }
    else
      _escPressed = false;
  }
}
