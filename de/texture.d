module de.texture;

import derelict.sdl.sdl;
import derelict.sdl.image;
import derelict.opengl.gl;
import derelict.opengl.extension.ext.framebuffer_object;

import core.logger;

class Texture
{
  SDL_Surface* _surface;
  int _width;
  int _height;
  GLuint _tex;

  public GLuint id() { return _tex; }
  public int width() { return _width; }
  public int height() { return _height; }

  public this(int width, int height)
  {
    _width = width, _height = height;
    createTexture(null);
  }

  public this(char[] filename)
  {
    readSurface(filename);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    createTexture(_surface.pixels);
    Logger.instance.message("Created texture from file: " ~ filename);
  }

  void readSurface(char[] filename)
  {
    _surface = IMG_Load(toStringz(filename));  

    if (_surface is null)
      throw new Error(format("Unable to load texture %s", filename));

    _width = _surface.w;
    _height = _surface.h;
  }

  void createTexture(void* pixels)
  {
    glGenTextures(1, &_tex);
    glBindTexture(GL_TEXTURE_2D, _tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //  type should be GL_UNSIGNED_INT_8_8_8_8 on big endian
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, 
        GL_UNSIGNED_BYTE, pixels);
    unbind();
  }

  void bind()
  {
    glBindTexture(GL_TEXTURE_2D, _tex);
  }

  static void unbind()
  {
    glBindTexture(GL_TEXTURE_2D, 0);
  }

}

