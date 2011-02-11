module game.testmanager;

import core.logger;
import core.rand;

import game.gamemanager;
import derelict.opengl.gl;
import derelict.sdl.sdl;

import de.camera;
import de.texture;
import de.vertexbuffer;
import de.vertex;
import de.shaper;
import de.math;
import de.shader;
import de.doublebuffer;
import de.feedback;

//  A test manager for testing stuff (duh)

class TestManager
{
  const int RT_SIZE = 512;

  NullGameManager _gm;

  Camera _camera;

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
  DoubleBuffer _frame;
  Logger _log;
  Rand _rand;

  public void init(NullGameManager gm)
  {
    _log = Logger.instance;
    _gm = gm;

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

    _fb = gm.feedbackBuffer;

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

    _log.message("Init shader and fb in testmanager");
    _shader = _gm.shaders["blur"];
    _shader.bind();
    _log.message("Setting coefficients");
    _shader["coefficients"] = _kernel;
    _log.message("Setting offsets");
    _shader.setUniform2fv("offsets", hoffsets);
    _shader.unbind();

    _fb.shader = _shader;
    
    _rand = new Rand();
  }

  public void move(float elapsed)
  {
    static float scaleElapsed = 0;

    scaleElapsed += elapsed;
    _rotation += elapsed * 64.0;

    if (_rotation > 360)
      _rotation -= 360;

    if (_scale < 1.0 && scaleElapsed > 0.01)
    {
      _scale *= (1 + scaleElapsed * 3);
      scaleElapsed = 0;
    }

    SDL_Delay(10);
  }

  public void draw()
  {
    _gm.screen.beginScene();

    Vector rv = Vector.create(_rand.nextFloat(0.15f), _rand.nextFloat(0.15f));
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

    _gm.screen.endScene();
  }


}

