module de.surface;

import de.framebuffer;
import de.texture;

import derelict.opengl.gl;
import derelict.opengl.gl15;

//  A shader surface encapsulates a texture map and a framebuffer
class Surface
{
  Texture _texture;
  FrameBuffer _frameBuffer;

  public this(int width, int height)
  {
    _texture = new Texture(width, height);
    _frameBuffer = new FrameBuffer(_texture);
  }

  public void bind()
  {
    _frameBuffer.bind();
    glViewport(0, 0, _texture.width, _texture.height);
    // glMatrixMode(GL_PROJECTION);
    // glLoadMatrixf(surface->projection);
    // glMatrixMode(GL_MODELVIEW);
    // glLoadMatrixf(surface->modelview);
    // boundSurface = surface;
  }

  public Texture texture() { return _texture; }
  public FrameBuffer frameBuffer() { return _frameBuffer; }
}
