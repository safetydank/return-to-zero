module game.field; 

import core.util;
import core.logger;
import std.math;
import std.stream;

import derelict.opengl.gl;

import core.rand;

import de.math;
import de.screen;
import de.doublebuffer;
import de.shader;
import de.shaper;
import de.vertexbuffer;
import de.vertex;
import de.colorset;

import game.ship;
import game.gamemanager;
import game.levelmanager;
import game.effects;

public enum Effect_t
{
  BRAID,
  ROSE,
  CUBE,
  SPHERE
}

public struct Effect
{
  Effect_t method;
  int frameFrequency;   // will run the effect every N draws
  float beginTime;      // delay time before starting this effect
  float clockDivider;   // use 1.0 for normal rate, 0.5 for double rate, 2 for slower

  float colorAdvance;   // proportion to advance the colorset

  int iterations;       // number of times to loop through this effect in 1 pass
  float scale;          // the maximum amount to scale to over the course of the effect
  bool  sinScale;       // Use sinusoidal scaling?
  float scaleClock;     // Otherwise linearly scale out cycling every scaleClock seconds
  float scaleModFactor;
  float iterRotation;   // how much to rotate on each iteration (degrees)
  bool  flipRotation;   // oscillate between rotation angles each iteration?

  int   colorset;       //  refers to a color index in Field class
  Vector translate;        //  final translation vector of the drawn effect
  bool   disableAdditive;  //  Set to true to disable additive blending if you get white patches, otherwise leave it

  //  internal use
  float clock;

  static Effect createDefault()
  {
    Effect effect;

    effect.method = Effect_t.BRAID;
    effect.frameFrequency = 0;
    effect.beginTime = 0;
    effect.clockDivider = 1.0f;
    effect.iterations = 3;
    effect.colorAdvance = 1.0f;
    effect.scale = 8.0f;
    effect.sinScale = false;
    effect.scaleClock = 8.0f;
    effect.scaleModFactor = 0.95f;
    effect.iterRotation = 32;
    effect.colorset = 0;
    effect.flipRotation = true;
    effect.translate = Vector.zero;

    return effect;
  }
}


class Field
{
  // private static Rand rand;
  const float FIELD_WIDTH   = 45.0;
  const float FIELD_HEIGHT  = 45.0;

  private Vector _size;
  private Vector _eyePos, _eyePosSize;
  private Ship _ship;
  private Screen _screen;
  private Shader _shader;

  Rand _rand;

  NullGameManager _gm;
  LevelManager _lm;

  ColorSet[] _colors;

  // a braid
  private VertexBuffer!(PosVertex) _braid;
  // a 5 petal rose
  private VertexBuffer!(PosVertex) _rose5;
  // a cube
  private VertexBuffer!(PosVertex) _cube;
  // a sphere
  private VertexBuffer!(PosVertex) _sphere;

  float _clock = 0;
  float _ang = 0;
  float _r, _g, _b;

  float shake = 0;

  public const float EYE_POS_Z = 20.0f;

  Effect[] _effectList = null;

  public void init()
  {
    createColors();
    createMeshes();

    _effectList = MyFatGoldChains();
    // _effectList = GoldBraids();
    // _effectList = BlueSinCube();
  }

  public void reset()
  {
    _clock = 0;
  }

  void createColors()
  {
    // gold = 0
    _colors ~= new ColorSet(100.0, 0.6, 0.4, 0.2, 0.5);
    // red = 1
    _colors ~= new ColorSet(100.0, 0.5, 0.1, 0.06, 0.5);
    // green = 2
    _colors ~= new ColorSet(100.0, 0.5, 1.0, 0.6, 0.5);
    // blue = 3
    _colors ~= new ColorSet(100.0, 0.3, 0.3, 0.9, 0.5);

    // bright gold = 4
    _colors ~= new ColorSet(100.0, 0.6, 0.4, 0.2, 1.0);
    // bright red = 5
    _colors ~= new ColorSet(100.0, 0.5, 0.1, 0.06, 1.0);
    // bright green = 6
    _colors ~= new ColorSet(100.0, 0.5, 1.0, 0.6, 1.0);
    // bright blue = 7
    _colors ~= new ColorSet(100.0, 0.3, 0.3, 0.9, 1.0);

    // bright lime green = 8
    _colors ~= new ColorSet(100.0, 0.7, 1.0, 0.2, 1.0);
    // dark purple = 9
    _colors ~= new ColorSet(100.0, 0.7, 0.3, 0.7, 0.5);
    // bright purple = 10
    _colors ~= new ColorSet(100.0, 0.7, 0.3, 0.7, 1.0);
    // bright lime green (with additive disabled) = 11
    _colors ~= new ColorSet(100.0, 0.9, 1.0, 0.2, 1.0);

    // bright turquise blue (with additive disabled) = 12
    _colors ~= new ColorSet(100.0, 0.3, 0.7, 0.9, 1.0);
    // bright aqua blue (with additive disabled) = 13
    _colors ~= new ColorSet(100.0, 0.3, 0.9, 0.9, 1.0);
    // bright greeny blue (with additive disabled) = 14
    _colors ~= new ColorSet(100.0, 0.3, 1.0, 0.8, 1.0);

    // firey = 15
    _colors ~= new ColorSet(100.0, 0.5, 0.1, 0.05, 0.5);
    // firey (with additive disabled) = 16
    _colors ~= new ColorSet(100.0, 0.5, 0.1, 0.05, 1.0);
    //_colors ~= new ColorSet(100.0, 0.7, 0.1, 0.2, 1.0);  // purpley pink

    // almost lime green (with additive disabled) = 17
    _colors ~= new ColorSet(100.0, 0.5, 1.0, 0.2, 1.0);
    // almost forest green (with additive enabled) = 18
    _colors ~= new ColorSet(100.0, 0.0, 0.4, 0.1, 0.5);
    // dark green/blue (with additive enabled) = 19
    _colors ~= new ColorSet(100.0, 0.0, 0.4, 0.4, 0.4);

    // dark gold = 20
    _colors ~= new ColorSet(100.0, 0.6, 0.4, 0.2, 0.4);
  }

  void createMeshes()
  {
    //  Create the braid
    PosVertex[] braidv;
    createBraid(braidv, 1200, 1.0f, 0.06f, 60);

    Logger.instance.message(format("Braid verts: %d", braidv.length));
    _braid = new VertexBuffer!(PosVertex)(braidv.length);
    _braid.writeBatch(GL_LINE_STRIP, braidv);

    //  Create a rose
    PosVertex[] rosev;
    createRose(rosev, 1200, 1.0f, 5);

    Logger.instance.message(format("Rose verts: %d", rosev.length));
    _rose5 = new VertexBuffer!(PosVertex)(rosev.length);
    _rose5.writeBatch(GL_LINE_STRIP, rosev);

    //  Create a cube
    PosVertex[] cubev;
    createCube(cubev, 1000, 1.0f);

    Logger.instance.message(format("Cube verts: %d", cubev.length));
    _cube = new VertexBuffer!(PosVertex)(cubev.length);
    _cube.writeBatch(GL_POINTS, cubev);

    //  Create a sphere
    PosVertex[] spherev;
    createSphere(spherev, 8000, 1.0f);  // Some vertices will be culled

    Logger.instance.message(format("Sphere verts: %d", spherev.length));
    _sphere = new VertexBuffer!(PosVertex)(spherev.length);
    _sphere.writeBatch(GL_POINTS, spherev);
  }

  public this(NullGameManager gm)
  {
    _gm = gm;
    _lm = gm.levelManager;
    _screen = gm.screen;
    _rand = new Rand();

    _size = Vector.create(FIELD_WIDTH, FIELD_HEIGHT);
    _eyePos = Vector.create(0, 0);
    _eyePosSize = Vector.create(_size.x - 40, _size.y - 30);

    _shader = _gm.shaders["blur"];

    _r = _g = _b = 0;

  }

  public void setShip(Ship ship)
  {
    _ship = ship;
  }

  public bool inField(Vector pos)
  {
    const float XRANGE = FIELD_WIDTH / 2.0;
    const float YRANGE = FIELD_HEIGHT / 2.0;

    return (inRange(pos.x, -XRANGE, XRANGE) 
        && inRange(pos.y, -YRANGE, YRANGE));
  }

  public bool clampToField(inout Vector pos)
  {
    const float XRANGE = FIELD_WIDTH / 2.0;
    const float YRANGE = FIELD_HEIGHT / 2.0;

    bool result = clampToRange(pos.x, -XRANGE, XRANGE);
    result |= clampToRange(pos.y, -YRANGE, YRANGE);

    return result;
  }

  public bool clampToEye(inout Vector pos)
  {
    float XRANGE = _eyePosSize.x / 2.0;
    float YRANGE = _eyePosSize.y / 2.0;

    bool result = clampToRange(pos.x, -XRANGE, XRANGE);
    result |= clampToRange(pos.y, -YRANGE, YRANGE);

    return result;
  }

  public void move(float elapsed)
  {
    _clock += elapsed;
    foreach (colorset; _colors)
      colorset.move(elapsed);
  }

  public void draw()
  {
    _gm.feedbackBuffer.applyShader();
    _gm.feedbackBuffer.draw();
    renderBackbuffer();

    _gm.screen.setViewport();
    _gm.screen.setPerspective();
    _lm.camera.setView();
    // drawBraid(_braidScale);
  }

  private void drawMesh(Effect effect, VertexBuffer!(PosVertex) vb)
  {
    float clock = effect.clock / effect.clockDivider;

    if (effect.disableAdditive == true)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glTranslatef(effect.translate.x, effect.translate.y, effect.translate.z);

    float scale;
    if (effect.sinScale)
      scale = effect.scale * ((0.5 * sin(clock)) + 1.0);
    else
      scale = effect.scale * (clock % effect.scaleClock);

    glScalef(scale, scale, scale);
    glRotatef(60 * clock, 0, 0, 1);

    ColorSet colorSet = _colors[effect.colorset];
    Vector color = colorSet.color;
    glColor4f(color.x, color.y, color.z, color.w);

    for (int i = 0; i < effect.iterations; ++i)
    {
      colorSet.move(effect.colorAdvance);
      color = colorSet.color;
      glPushMatrix();
      glScalef(effect.scaleModFactor, effect.scaleModFactor, effect.scaleModFactor);
      float rotate = effect.iterRotation;
      if (effect.flipRotation && (i % 2))
        rotate = -rotate;
      glRotatef(rotate, 0, 0, 1.0);
      glColor4f(color.x, color.y, color.z, color.w);
      vb.drawBatch();
    }

    for (int i=0; i < effect.iterations; ++i)
      glPopMatrix();

    glPopMatrix();

    if (effect.disableAdditive == true) 
      glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  }

  private void renderBackbuffer()
  {
    static int freqDivider = 0;

    //  Draw to backbuffer
    _gm.feedbackBuffer.bind();
    _gm.feedbackBuffer.setPerspective();
    _lm.camera.setView();

    if (_effectList !is null)
    {
      foreach (effect; _effectList)
      {
        float clock = _clock - effect.beginTime;
        bool runFreq = (effect.frameFrequency == 0) 
          || (++freqDivider % effect.frameFrequency == 0);

        if (runFreq && clock >= 0) {
          effect.clock = clock;
          runEffect(effect);
        }
      }
    }

    _gm.feedbackBuffer.unbind();
  }

  void runEffect(Effect effect)
  {
    switch (effect.method)
    {
      case Effect_t.BRAID:
        drawMesh(effect, _braid);
        break;
      case Effect_t.ROSE:
        drawMesh(effect, _rose5);
        break;
      case Effect_t.CUBE:
        drawMesh(effect, _cube);
        break;
      case Effect_t.SPHERE:
        drawMesh(effect, _sphere);
        break;
    }
  }

  public void setEffects(Effect[] effects)
  {
    _effectList = effects;
  }
}
