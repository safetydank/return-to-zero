module de.vertexbuffer;

import core.logger;

import derelict.opengl.gl;
import derelict.opengl.gl15;
import derelict.opengl.glext;

import de.math;
import de.vertex;

/**
 * A dynamic vertex buffer object, templated on the vertex type
 */
class VertexBuffer(VERTEX)
{
  protected final uint _c_bufVertices;
  protected uint _c_vertices = 0;
  public uint c_bufVertices() { return _c_bufVertices; }

  const int VERTEX_SIZE = VERTEX.sizeof;

  GLuint _vbo;
  int _primitiveType;
  uint _c_primitives;

  public this(uint c_bufVertices)
  in
  {
    assert(c_bufVertices > 0);
  }
  out
  {
    assert(_vbo);
  }
  body
  {
    _c_bufVertices = c_bufVertices;

    //  Create the vertex buffer object
    glGenBuffers(1, &_vbo);
    bind();
    glBufferData(GL_ARRAY_BUFFER, VERTEX_SIZE * _c_bufVertices, null, 
        GL_STREAM_DRAW);
    unbind();
  }

  ~this()
  {
    glDeleteBuffers(1, &_vbo);
  }

  public void writeBatch(int primitiveType, VERTEX[] vertexList)
  {
    writeBatch(primitiveType, cast(void*) vertexList.ptr, vertexList.length);
  }

  //  Write a batch of primitives for rendering
  public void writeBatch(int primitiveType, void* vertexArray, uint c_vertices)
  {
    bind();
    glInterleavedArrays(VERTEX.FORMAT, 0, null);
    glBufferSubData(GL_ARRAY_BUFFER, 0, VERTEX_SIZE * c_vertices, vertexArray);
    setPrimitives(primitiveType, c_vertices);
    // Logger.instance.message(format("Wrote %d vertices _c_primitives %d to vertex buffer", c_vertices, _c_primitives));
    unbind();
  }

  //  XXX untested!
  public void* map(bool stream)
  {
    bind();
    glBufferData(GL_ARRAY_BUFFER, VERTEX_SIZE * _c_bufVertices, null, 
        stream ? GL_STREAM_DRAW : GL_STATIC_DRAW);
    glInterleavedArrays(VERTEX.FORMAT, 0, null);
    return glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
  }

  public bool unmap()
  {
    return (glUnmapBuffer(GL_ARRAY_BUFFER) != 0);
  }

  protected void bind()
  {
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
  }

  protected static void unbind()
  {
    glBindBuffer(GL_ARRAY_BUFFER, 0);
  }

  public void drawBatchDbg()
  {
    Logger.instance.message(format("drawBatch: Drawing primitive type %d c_vertices %d", _primitiveType, _c_vertices));
    drawBatch();
  }

  public void drawBatch()
  in
  {
    assert(_c_vertices > 0);
  }
  body
  {
    bind();
    glInterleavedArrays(VERTEX.FORMAT, 0, null);
    glDrawArrays(_primitiveType, 0, _c_vertices);
    unbind();
  }

  protected void setPrimitives(int primitiveType, int c_vertices)
  {
    _primitiveType = primitiveType;
    _c_vertices = c_vertices;
    switch (_primitiveType)
    {
        case GL_POINTS:         _c_primitives = c_vertices;     break;
        case GL_TRIANGLES:      _c_primitives = c_vertices / 3; break;
        case GL_TRIANGLE_STRIP: _c_primitives = c_vertices - 2; break;
        case GL_TRIANGLE_FAN:   _c_primitives = c_vertices - 2; break;
        case GL_LINE_STRIP:     _c_primitives = c_vertices - 1; break;
    }
  }
}

