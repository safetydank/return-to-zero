module de.vertex;

import derelict.opengl.gl;
import de.math;

//  All-purpose vertex class, defines texture coords, color components,
//  normals and position
struct Vertex
{
  float tu, tv;
  float r, g, b, a;
  float nx, ny, nz;
  float x, y, z;

  static const FORMAT = GL_T2F_C4F_N3F_V3F;

  public static Vertex create(float x, float y, float z)
  {
    return create(0., 0., 1., 1., 1., 1., x, y, z);
  }

  public static Vertex create(float tu, float tv, Vector pos)
  {
    return create(tu, tv, Vector.create(1., 1., 1., 1.), pos);
  }

  public static Vertex create(float tu, float tv, Vector color, Vector pos)
  {
    return create(tu, tv, color, pos.x, pos.y, pos.z);
  }

  public static Vertex create(float tu, float tv, 
      Vector color, float x, float y, float z) 
  {
    return create(tu, tv, color.x, color.y, color.z, color.w, x, y, z);
  }

  public static Vertex create(float tu, float tv, 
      float r, float g, float b, float a, 
      float x, float y, float z) 
  { 
    Vertex v;

    v.tu = tu;
    v.tv = tv;

    v.r = r;
    v.g = g;
    v.b = b;
    v.a = a;

    v.nx = 0;
    v.ny = 0;
    v.nz = 1.0;

    v.x = x;
    v.y = y;
    v.z = z;

    return v;
  }

  public static void setColor(inout Vertex v, float r, float g, float b, float a = 1.0)
  {
    v.r = r;
    v.g = g;
    v.b = b;
    v.a = a;
  }

  public static void setTexture(inout Vertex v, float tu, float tv)
  {
    v.tu = tu;
    v.tv = tv;
  }
}

//  Basic textured vertex, defines position and texture coords only.  Used for bitmap
//  font rendering
struct BasicVertex
{
  float tu, tv;
  float x, y, z;

  static const FORMAT = GL_T2F_V3F;

  public static BasicVertex create(float tu, float tv, Vector pos)
  {
    return BasicVertex.create(tu, tv, pos.x, pos.y, pos.z);
  }

  public static BasicVertex create(float tu, float tv, float x, float y, float z)
  {
    BasicVertex v;

    v.tu = tu;
    v.tv = tv;
    v.x = x;
    v.y = y;
    v.z = z;

    return v;
  }
}

//  A positional vertex describing position only
struct PosVertex
{
  float x, y, z;
  
  static const FORMAT = GL_V3F;
}

