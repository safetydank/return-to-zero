module de.feedback;

import de.math;
import de.doublebuffer;
import de.shader;
import de.screen;
import de.texture;

import derelict.opengl.gl;

class FeedbackBuffer
{
  DoubleBuffer _buf;
  Screen _screen;
  Shader _shader;
  public Shader shader() { return _shader; }
  int _width, _height;
  public int width() { return _width; }
  public int height() { return _height; }

  //  XXX all shaders have a uniform "TextureIn" to specify the 
  //  input texture
  public Shader shader(Shader s) 
  in
  {
    assert(_buf);
  }
  body
  { 
    _shader = s; 
    if (shader !is null)
    {
      _shader.bind();
      _shader["TextureIn"] = _buf.frontTexture;
      _shader.unbind();
    }
    return _shader;
  }

  public this(int size, Screen screen)
  {
    _width = _height = size;
    _buf = new DoubleBuffer(_width, _height);
    _screen = screen;

    clear();
  }

  public void clear()
  {
    //  Clear textures
    _buf.frontBuffer.bind();
    _screen.clear();
    _buf.frontBuffer.unbind();

    _buf.backBuffer.bind();
    _screen.clear();
    _buf.backBuffer.unbind();
  }

  //  Bind to render to the surface
  public void bind()
  {
    _buf.frontBuffer.bind();
  }

  public void setPerspective()
  {
    _screen.setPerspective(_width, _height);
  }

  public void setOrtho()
  {
    _screen.setViewport(_width, _height);
    _screen.setOrtho(_width, _height);
  }

  public void unbind()
  {
    _buf.frontBuffer.unbind();
  }

  public void applyShader()
  {
    if (_shader !is null)
    {
      //  Apply shader to rendered texture
      _buf.backBuffer.bind();
      glDisable(GL_BLEND);
      // _screen.clear();
      _screen.setViewport();
      _screen.setOrtho();

      _shader.bind();
      _shader["TextureIn"] = _buf.frontTexture;
      drawOrthoQuad(_width, _height);
      _shader.unbind();

      glEnable(GL_BLEND);
      _buf.backBuffer.unbind();

      //  Swap front/back buffers and render to screen
      _buf.swap();
    }
  }

  public void draw()
  {
    // applyShader();
    _screen.setViewport();
    _screen.setOrtho();

    _buf.frontTexture.bind();
    drawOrthoQuad(_screen.width, _screen.height);
    Texture.unbind();
  }

  void drawOrthoQuad(int width, int height)
  {
    glBegin(GL_TRIANGLE_FAN);
    glTexCoord2f(0., 0.);
    glNormal3f(0., 0., 1.);
    glVertex3f(0, 0, 0);
    glTexCoord2f(0., 1.);
    glNormal3f(0., 0., 1.);
    glVertex3f(0, height, 0);
    glTexCoord2f(1., 1.);
    glNormal3f(0., 0., 1.);
    glVertex3f(width, height, 0);
    glTexCoord2f(1., 0.);
    glNormal3f(0., 0., 1.);
    glVertex3f(width, 0, 0);
    glEnd();
  }
}
