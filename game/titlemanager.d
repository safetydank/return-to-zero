module game.titlemanager;

import core.logger;
import core.util;
import core.rand;

import std.math;

import de.config;
import de.text;
import de.texture;
import de.vertex;
import de.vertexbuffer;
import de.math;
import de.twinstickpad;
import de.colorset;
import de.shaper;
import de.shader;
import de.feedback;
import de.camera;
import de.sound;
import de.mouse;

import derelict.opengl.gl;
import derelict.sdl.sdl;
import game.gamemanager;

//  Hacked title sequence manager
//
//  Basic order:
//  Screen 1:
//    Expanding Brain (5s)
//  Screen 2:
//    Return to Zero
//  Screen 3(?):
//    Title, press button to start
class TitleManager
{
  Logger _log;

  const float EXPAND_TITLE_TIME = 6.0;
  const float RTZ_TITLE_TIME = 1.5;
  const char[] RTZ_STRING = "return to zero";

  Texture _fontTexture;
  TextLineRenderer _textRenderer;

  VertexBuffer!(BasicVertex) _text1;
  VertexBuffer!(BasicVertex) _text2;
  VertexBuffer!(BasicVertex) _logo;
  
  int RT_SIZE;

  Vector _textColor;
  float _textSize;
  float _textWidth;
  Vector _centerPos;
  Vector _titlePos;
  Vector _offset;

  Vector _patternBegin;
  Vector _patternEnd;

  NullGameManager _gm;
  Rand rand;

  //  Logo texture
  Texture _tex_logo;
  VertexBuffer!(Vertex) _vb_logo;

  float _rotation = 0;
  float _scale = 0.1;

  Shaper!(Vertex) _shaper;
  Shader _shader;

  //  Shader parameters
  // float[5] _kernel = [0.1, 0.4, 0.6, 0.4, 0.1];
  float[5] _kernel = [0.1, 0.2, 0.4, 0.2, 0.1];
  float hoffsets[10];
  float voffsets[10];

  FeedbackBuffer _fb;

  Camera _camera;

  ColorSet _colorset;

  float _elapsed;

  enum TitleState
  {
    EXPANDINGBRAIN,
    RETURNTOZERO,
    BEGIN
  }

  public TitleState _state;
  void delegate() fnDraw;

  //  Rendering state
  float _alpha;

  bool _begin = false;
  public void init(NullGameManager gm)
  {
    _log = Logger.instance;

    _gm = gm;
    _fontTexture = gm.textures["font"];
    _text1 = TextLineRenderer.createTextBuffer();
    _text2 = TextLineRenderer.createTextBuffer();
    _textRenderer = new TextLineRenderer(_fontTexture, 16);
    _textColor = Vector.create(1,1,1,1);
    rand = new Rand();

    _elapsed = 0;
    setTextSizeDivider(32.0);

    _state = TitleState.EXPANDINGBRAIN;
    fnDraw = &drawEx;
    float textWidth = _textRenderer.renderString("expanding brain", _text1);
    _log.message(format("expanding brain: text width %f", textWidth));
    _centerPos = centerPos(textWidth, _textRenderer.charHeight);
    _log.message("begin title sequence: expanding brain");

    _colorset = new ColorSet(5.0, Vector.create(0.75, 0.75, 0.993, 0.97));
    _colorset.add(0.75, 0.993, 0.75, 0.97);
    _colorset.add(0.993, 0.75, 0.75, 0.97);

    _patternBegin = Vector.zero;
    _patternEnd = Vector.zero;


    RT_SIZE = Config.instance.quadsize;
    initLogo();
  }

  void initLogo()
  {
    _shaper = new Shaper!(Vertex)();

    _tex_logo = _gm.textures["logo"];
    _vb_logo = new VertexBuffer!(Vertex)(6);

    //  Create logo quad
    Vertex[6] bb;
    _shaper.writeBillboard(bb, 0, 
        ShapeAttr.create(Vector.zero, Vector.create(1,1,1,1), 3.0));
    _vb_logo.writeBatch(GL_TRIANGLES, bb);

    //  Camera
    _camera = new Camera(Vector.create(0, 0, 10.0), Vector.create(0,0,0), 
        Vector.create(0,1,0));

    _fb = _gm.feedbackBuffer;

    //  init shader and framebuffers
    float offset = 1.0f / _fb.width;
    int dir = 1;  // horizontal

    for (int c=0; c<5; ++c)
    {
      hoffsets[c * 2 + 0] = offset * (c - 2);
      hoffsets[c * 2 + 1] = 0;
    }

    for (int c=0; c<5; ++c)
    {
      voffsets[c * 2 + 0] = 0;
      voffsets[c * 2 + 1] = offset * (c - 2);
    }

    _log.message("Init shader and fb in titlemanager");
    _shader = _gm.shaders["blur"];
    _shader.bind();
    _log.message("Setting coefficients");
    _shader["coefficients"] = _kernel;
    _log.message("Setting offsets");
    _shader.setUniform2fv("offsets", hoffsets);
    _shader.unbind();

    _fb.shader = _shader;
  }

  void setTextSizeDivider(float div)
  {
    _textSize = _gm.screen.height / 32.0;
  }

  public void move(float elapsed)
  {
    if (_begin == false)
    {
      _begin = true;
      SoundManager.playSe("expanding");
    }

    switch(_state)
    {
      case TitleState.EXPANDINGBRAIN:
        stepEx(elapsed);
        break;
      case TitleState.RETURNTOZERO:
        stepRTZ(elapsed);
        break;
      case TitleState.BEGIN:
        stepBegin(elapsed);
        break;
      default:
        break;
    }
  }
  
  public void draw()
  {
    _gm.screen.beginScene();
    fnDraw();
    _gm.screen.endScene();
  }

  Vector centerPos(float textWidth, float textHeight)
  {
    float x = (_gm.screen.width - textWidth * _textSize) / 2.0;
    float y = (_gm.screen.height - _textSize) / 2.0;
    return Vector.create(x, y, 0);
  }

  void stepEx(float elapsed)
  {
    static float scaleElapsed = 0;

    _elapsed += elapsed;
    scaleElapsed += elapsed;
    _rotation += elapsed * 64.0;
    if (_rotation > 360)
      _rotation -= 360;

    if (_scale < 1.0 && scaleElapsed > 0.01)
    {
      _scale *= (1 + scaleElapsed * 3);
      scaleElapsed = 0;
    }

    //  Switch to display RTZ
    if (_elapsed > EXPAND_TITLE_TIME)
    {
      _fb.clear();
      _log.message("title sequence: RTZ");
      _elapsed = 0;
      fnDraw = &drawRTZ;
      _state = TitleState.RETURNTOZERO;
      float textWidth = _textRenderer.renderString(RTZ_STRING, _text2);
      _centerPos = centerPos(textWidth, _textRenderer.charHeight);
      SoundManager.playBgm("title");
    }

    _alpha = min((_elapsed / (3.0 * EXPAND_TITLE_TIME / 4.0)), 1.0);
  }

  void stepRTZ(float elapsed)
  {
    static bool done = false;
    static float[RTZ_STRING.length] spaces;

    _elapsed += elapsed;
    //  Switch to begin screen
    if (_elapsed > RTZ_TITLE_TIME)
    {
      _log.message("title sequence: begin");
      _elapsed = 0;
      fnDraw = &drawBegin;
      _state = TitleState.BEGIN;
      _titlePos = _centerPos;
      _textWidth = _textRenderer.renderString("fire to begin", _text1);
      _centerPos = centerPos(_textWidth, _textRenderer.charHeight);
      // _gm.feedbackBuffer.shader = _gm.shaders["blur"];
    }

    float t = _elapsed / (RTZ_TITLE_TIME - 1.5);
    const float PI_SECTION = (PI / 2.0) * 0.7f;
    float tt = (t < 1.0) ? cos(PI_SECTION*(1 - t)) : 1.0;
    _alpha = tt;
    if (tt >= 1.0) done = true;
    // float tt = t;

    spaces[0] = 0;
    int textCenterOffset = RTZ_STRING.length / 2;

    const float SEPARATION = 1.6f;
    for (int i=1; i < spaces.length; ++i)
    {
      int ratio = core.util.abs(i - textCenterOffset);
      float maxOffset = (cast(float) ratio / RTZ_STRING.length) * SEPARATION;
      // _log.message(format("maxoffset %f t %f spaces %d == %f", maxOffset, t, i, maxOffset * t));
      spaces[i] = (maxOffset * tt) - 0.4f;
    }

    if (!done)
    {
      _textWidth = _textRenderer.renderString(RTZ_STRING, _text2, spaces);
      _centerPos = centerPos(_textWidth, _textRenderer.charHeight);
    }
  }

  void stepBegin(float elapsed)
  {
    TwinStickPadState input = _gm.pad.getState();
    MouseState ms = _gm.mouse.getState();
    _elapsed += elapsed;

    if (_elapsed > 60 * PI)
      _elapsed -= 60 * PI;

    cycleColor(elapsed);

    //  Lissajous
    _offset = Vector.create(6 * sin(3 * _elapsed * 0.5f), 3 * sin(4 * _elapsed * 0.5f), 0);

    _patternBegin = _patternEnd;
    _patternEnd = Vector.create(6 * sin(5 * _elapsed * 0.3f), 3 * sin(4 * _elapsed * 0.3f), 0);

    if (input.button != 0 || ms.button != 0)
    {
      _log.message("start level");
      _gm.startPlaying();
    }
    SDL_Delay(10);
  }

  void cycleColor(float elapsed)
  {
    _colorset.move(elapsed);
    // auto shader = _gm.shaders["blur"];
    // shader.bind();
    // shader["Color"] = _colorset.color;
    // shader.unbind();
  }

  void drawEx()
  {
    _gm.screen.setViewport();
    _gm.screen.setOrtho();
    glEnable(GL_BLEND);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glTranslatef(_centerPos.x, _centerPos.y, 0);
    glScalef(_textSize, _textSize, 0);
    glColor4f(1, 1, 1, _alpha);
    _textRenderer.bind();
    _text1.drawBatch();
    _textRenderer.unbind();
    glPopMatrix();

    drawLogo();
  }

  void drawLogo()
  {
    Vector rv = Vector.create(rand.nextFloat(0.15f), rand.nextFloat(0.15f));
    //  Render scene to texture
    _fb.bind();
    _gm.screen.setPerspective(RT_SIZE, RT_SIZE);
    // _gm.screen.clear();
    _camera.pos.z = 6.0;
    _camera.setView();

    glEnable(GL_BLEND);
    glPushMatrix();
    glTranslatef(rv.x, rv.y, 0);
    glRotatef(_rotation, 0, 0, -1.0);
    glScalef(_scale, _scale, _scale);
    _tex_logo.bind();
    _vb_logo.drawBatch();
    glPopMatrix();
    _fb.unbind();

    for (int i=0; i < 1; ++i)
    {
      _fb.shader.bind();
      _shader.setUniform2fv("offsets", hoffsets);
      _shader.unbind();
      _fb.applyShader();

      _fb.shader.bind();
      _shader.setUniform2fv("offsets", voffsets);
      _shader.unbind();
      _fb.applyShader();
    }

    _fb.draw();
  }


  void drawRTZ()
  {
    _gm.screen.setViewport();
    _gm.screen.setOrtho();
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glTranslatef(_centerPos.x, _centerPos.y, 0);
    glColor4f(1,1,1,_alpha);
    glScalef(_textSize, _textSize, 0);
    _textRenderer.bind();
    _text2.drawBatch();
    _textRenderer.unbind();
    glPopMatrix();
  }

  void drawBegin()
  in
  {
    assert(_gm.feedbackBuffer);
  }
  body
  {
    Vector color = _colorset.color;

    _gm.feedbackBuffer.bind();
    _gm.feedbackBuffer.setOrtho();
    drawTitle(color);

    _gm.feedbackBuffer.unbind();
    _gm.feedbackBuffer.applyShader();
    _gm.feedbackBuffer.draw();

    _gm.screen.setViewport();
    _gm.screen.setOrtho();

    drawTitle(Vector.create(1,1,1,1));

    //  Draw "fire to play" text
    glPushMatrix();
    glColor4f(1,1,1,core.util.abs(sin(2*_elapsed)));
    glScalef(_textSize * 0.8f, _textSize * 0.8f, 0);
    _textRenderer.bind();
    _text1.drawBatch();
    glPopMatrix();
    glColor4f(1,1,1,1);

    // _gm.screen.setViewport();
    // _gm.screen.setOrtho();
    // glBegin(GL_LINES);
    // glVertex3f(_patternBegin.x, _patternBegin.y, -1.0);
    // glVertex3f(_patternEnd.x, _patternEnd.y, -1.0);
    glEnd();

  }

  void drawTitle(Vector col)
  {
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glTranslatef(_offset.x * _textSize - _textWidth, _offset.y * _textSize, 0);

    glPushMatrix();
    glTranslatef(_titlePos.x, _titlePos.y, 0);
    glScalef(_textSize, _textSize, 0);
    glColor4f(col.x, col.y, col.z, col.w);
    _textRenderer.bind();
    _text2.drawBatch();
    glPopMatrix();
    glPopMatrix();
  }
}
