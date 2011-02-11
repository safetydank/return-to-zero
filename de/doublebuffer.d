module de.doublebuffer;

import de.framebuffer;
import de.texture;

//  Two framebuffers and associated textures
class DoubleBuffer
{
  //  Index of active and last rendered framebuffers
  int _i_active;
  public int i_active() { return _i_active; }

  int _i_last;

  Texture _textures[2];
  FrameBuffer _buffers[2];

  //  Active texture / frame
  public Texture frontTexture() { return _textures[_i_active]; }
  public FrameBuffer frontBuffer() { return _buffers[_i_active]; }

  //  Previously rendered texture / frame
  public Texture backTexture() { return _textures[_i_last]; }
  public FrameBuffer backBuffer() { return _buffers[_i_last]; }

  public this(int width, int height)
  {
    for (int i=0; i<2; ++i)
    {
      _textures[i] = new Texture(width, height); 
      _buffers[i]  = new FrameBuffer(_textures[i]);
    }

    _i_last = _i_active = 0;
  }

  public void swap()
  {
    _i_last = _i_active;
    _i_active = (_i_active + 1) & 1;
  }
}

