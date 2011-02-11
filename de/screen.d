module expand.screen;

import std.string;
import std.c.windows.windows;

import core.logger;

import derelict.sdl.sdl;
import derelict.opengl.gl;
import derelict.opengl.extension.ext.framebuffer_object;

import de.config;
import de.math;
import de.vertexbuffer;

class Screen
{
  protected int _width;
  protected int _height;
  protected int _depth = 32;

  SDL_Surface* _surface;
  public SDL_Surface* surface() { return _surface; }

  const char[] CAPTION = "nullGL";
  const float NEARPLANE = 0.1;
  const float FARPLANE  = 1000;

  Logger _log;

  public int width() { return _width; }
  public int height() { return _height; }

  public Vector color(Vector v)
  {
    glColor4f(v.x, v.y, v.z, v.w);
    return v;
  }

  public Vector clearColor(Vector v)
  {
    glClearColor(v.x, v.y, v.z, v.w);
    return v;
  }

  private bool _b_insideScene;

  public ~this()
  {
  }

  public void init()
  {
    _log = Logger.instance;
    Config config = Config.instance;

    _width  = config.width;
    _height = config.height;
    bool fullscreen = config.fullscreen;

    // Initialize SDL
    if(SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO) < 0)
    {
      _log.message(format("SDL init error: %s", SDL_GetError));
      SDL_Quit();
      return 1;
    }

    // Create the screen surface (window)
    auto videoFlags = fullscreen ? SDL_FULLSCREEN : SDL_RESIZABLE;
    videoFlags |= SDL_OPENGL;

    _surface = SDL_SetVideoMode(_width, _height, _depth, videoFlags);
    if (_surface is null)
    {
      _log.message(format("Unable to set %d x %d video: %s", _width, _height, SDL_GetError));
      SDL_Quit();
      return 1;
    }	
    else
    {
      auto glversion = cast(int)(DerelictGL.availableVersion);
      _log.message(format("OpenGL version %d", glversion));
      if (glversion < 20)
        throw new Error("Error: requires OpenGL version >= 2.0");
      loadExtensions();
    }

    SDL_WM_SetCaption(toStringz(CAPTION), null);
    if (fullscreen)
      SDL_ShowCursor(SDL_DISABLE);

    initGL();
  }

  void loadExtensions()
  out
  {
    assert(EXTFramebufferObject.isEnabled);
  }
  body
  {
    auto c_extensions = DerelictGL.loadExtensions();
    _log.message(format("%d extensions loaded", c_extensions));
    if (!EXTFramebufferObject.isEnabled)
      _log.message(format("Framebuffer object extension could not be loaded, bailing..."));
  }

  private void initGL()
  {
    // checkCapabilities();
    // glEnableClientState(GL_COLOR_ARRAY);
    // glEnableClientState(GL_VERTEX_ARRAY);
    // glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glEnable(GL_LINE_SMOOTH);
    glShadeModel(GL_SMOOTH);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);

    glEnable(GL_TEXTURE_2D);

    setPerspective();
  }

  public void setPerspective(int width = 0, int height = 0)
  {
    if (width == 0) width = _width;
    if (height == 0) height = _height;

    setViewport(width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum(-NEARPLANE, NEARPLANE,
        -NEARPLANE * cast(GLfloat) _height / cast(GLfloat) _width,
         NEARPLANE * cast(GLfloat) _height / cast(GLfloat) _width,
         0.1, FARPLANE);
    glMatrixMode(GL_MODELVIEW);
  }

  public void setViewport(int width = 0, int height = 0)
  {
    if (width == 0) width = _width;
    if (height == 0) height = _height;

    glViewport(0, 0, width, height);
  }

  public void setOrtho(int width = 0, int height = 0)
  {
    if (width == 0) width = _width;
    if (height == 0) height = _height;

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, _width, 0, _height, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
  }

  public void clear()
  {
    glClear(GL_COLOR_BUFFER_BIT);
  }

  public void beginScene() 
  { 
    if (_b_insideScene) return;
    clear();
    _b_insideScene = true;
  }

  public void endScene()   
  { 
    if (!_b_insideScene) return;
    present();
    _b_insideScene = false;
  }

  private void present()    
  { 
    SDL_GL_SwapBuffers();
  }

  protected HWND getSDLWnd()
  {
    SDL_SysWMinfo wmInfo;
    SDL_GetWMInfo(&wmInfo);
    return cast(HWND)(wmInfo.window);
  }

	public void drawUsing(void delegate() command)
	{
		command();
	}

  public void close()
  {

  }

  public void handleError() 
  {
    GLenum error = glGetError();
    if (error == GL_NO_ERROR)
      return;
    throw new Exception("OpenGL error(" ~ std.string.toString(error) ~ ")");
  }

  //  GL convenience methods
  public static void glTranslate(Vector v)
  {
    glTranslatef(v.x, v.y, v.z);
  }
}
