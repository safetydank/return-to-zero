module de.text;

import de.texture;
import de.vertexbuffer;
import de.vertex;
import de.math;

import derelict.opengl.gl;

class TextLineRenderer
{
  const int MAX_LINE_LENGTH = 100;
  const float DT = 0.0625f;

  float _charWidth  = 1.0f;
  float _charHeight = 1.0f;

  public float charWidth(float f) { return _charWidth = f; }
  public float charHeight(float f) { return _charHeight = f; }
  public float charHeight() { return _charHeight; }
  public float charWidth()  { return _charWidth; }

  Texture _fontTexture;

  //  XXX unused, refactor with this value to replace DT etc.
  int _dim;

  BasicVertex[] _vertices;

  public this(Texture fontTexture, int dim = 16)
  out
  {
    assert(_fontTexture);
  }
  body
  {
    _fontTexture = fontTexture;
    _dim = dim;
    _vertices = new BasicVertex[MAX_LINE_LENGTH * 6];
  }

  public void bind() { _fontTexture.bind(); }
  public static void unbind() { Texture.unbind(); }

  static VertexBuffer!(BasicVertex) createTextBuffer()
  {
    auto vb = new VertexBuffer!(BasicVertex)(MAX_LINE_LENGTH * 6);
    return vb;
  }

  //  Render a string to a vertex buffer, with optional spacing
  //  array for adjusting the space between characters.  The spacing
  //  array values are proportional to the size of the font.
  //
  //  e.g.  "Hello"  [1,1,1,1,1] -> " H e l l o"
  //
  //  Returns width of the rendered string
  public float renderString(char[] str, VertexBuffer!(BasicVertex) vb, float[] spacing = null)
  in
  {
    assert(spacing is null || spacing.length == str.length);
  }
  body
  {
    float x = 0;
    int i_vertex = 0;
    int i_space = 0;

    foreach(c; str)
    {
      if (spacing !is null)
        x += (spacing[i_space++] * _charWidth);

      writeChar(c, i_vertex, x, 0);
      x += _charWidth;
    }

    vb.writeBatch(GL_TRIANGLES, _vertices.ptr, i_vertex);

    return x;
  }

  void writeChar(char ch, inout int i, float x, float y)
  {
    float tu, tv;
    textureOffsets(ch, tu, tv);
    tu += 0.001;
    tv += 0.001;
    float mu = tu + DT;
    float mv = tv + DT;

    _vertices[i++] = BasicVertex.create(tu, tv, x, y + _charWidth, 0);
    _vertices[i++] = BasicVertex.create(tu, mv, x, y, 0);
    _vertices[i++] = BasicVertex.create(mu, mv, x + _charWidth, y, 0);
    _vertices[i++] = BasicVertex.create(tu, tv, x, y + _charWidth, 0);
    _vertices[i++] = BasicVertex.create(mu, mv, x + _charWidth, y, 0);
    _vertices[i++] = BasicVertex.create(mu, tv, x + _charWidth, y + _charWidth, 0);
  }

  void textureOffsets(char c, out float tu, out float tv)
  {
    int code = (cast(int) c) - 32;
    int ix = code % 16;
    int iy = code / 16;

    tu = ix * DT;
    tv = iy * DT;
  }
}

