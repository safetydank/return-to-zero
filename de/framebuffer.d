module de.framebuffer;

import core.logger;

import derelict.opengl.gl;
import derelict.opengl.extension.ext.framebuffer_object;

import de.texture;

class FrameBuffer
{
  GLuint _fb;

  Texture _tex;

  GLuint _depthBuffer;

  public Texture texture() { return _tex; }

  public this(Texture tex)
  in
  {
    assert(tex);
    assert(tex.id);
  }
  body
  {
    glGenFramebuffersEXT(1, &_fb);
    bind();

    // Set up color_tex and depth_rb for render-to-texture
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,
        GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, tex.id, 0);

    // glGenRenderbuffersEXT(1, &_depthBuffer);
    // glBindRenderbufferEXT(1, _depthBuffer);
    // glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT24, tex.width, tex.height);
    //glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, 
    //    GL_RENDERBUFFER_EXT, _depthBuffer);

    // Check framebuffer completeness at the end of initialization.
    checkFramebufferStatus();

    unbind();
  }

  public ~this()
  {
    glDeleteFramebuffersEXT(1, &_fb);
  }

  void checkFramebufferStatus()
  {
    GLenum status;                                            
    status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT); 
    switch(status) 
    {                                          
      case GL_FRAMEBUFFER_COMPLETE_EXT:                       
        break;                                                
      case GL_FRAMEBUFFER_UNSUPPORTED_EXT:                    
        throw new Error("Framebuffer: Unsupported format");
        break;                                                
      default:                                                
        /* programming error; will fail on all hardware */    
        Logger.instance.message("OpenGL programming error: fails on all hardware");
        Logger.instance.message("This may be caused by video capture software putting OpenGL in an invalid state.");
        assert(0);                                            
    }
  }

  public void bind()
  {
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _fb);
  }

  static void unbind()
  {
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
  }
}
