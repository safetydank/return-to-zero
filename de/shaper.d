module de.shaper;

import core.util;

import de.vertexbuffer;
import de.vertex;
import de.math;

public struct ShapeAttr
{
  Vector pos;
  Vector color;
  Vector scale;
  Matrix rotation;

  static ShapeAttr create(Vector pos, Vector color, float scale)
  {
    return create(pos, color, Vector.create(scale, scale, scale));
  }

  static ShapeAttr create(Vector pos, Vector color, Vector scale)
  {
    ShapeAttr attr;
    attr.pos = pos;
    attr.scale = scale;
    attr.color = color;
    attr.rotation = Matrix.identity;
    return attr;
  }

  static ShapeAttr create(Vector pos, Vector color, Vector scale, Matrix rotation)
  {
    ShapeAttr attr;
    attr.pos = pos;
    attr.scale = scale;
    attr.color = color;
    attr.rotation = rotation;
    return attr;
  }  
}


//  Some basic shapes for drawing
class Shaper(VERTEX)
{
  Vector _defaultColor;

  //  Vertex positions for primitives
  Vector[3] _trianglev;
  Vector[6] _billboardv;

  public this()
  {
    _defaultColor = Vector.create(1,1,1,1);
    initTriangle();
    initBillboard();
  }

  void initTriangle()
  {
    _trianglev[0] = Vector.create(   0,  0.5, 0);
    _trianglev[1] = Vector.create( 0.5, -0.5, 0);
    _trianglev[2] = Vector.create(-0.5, -0.5, 0);
  }

  void initBillboard()
  {
    _billboardv[0] = Vector.create(-0.5,  0.5, 0);
    _billboardv[1] = Vector.create(-0.5, -0.5, 0);
    _billboardv[2] = Vector.create( 0.5, -0.5, 0);
    _billboardv[3] = Vector.create(-0.5,  0.5, 0);
    _billboardv[4] = Vector.create( 0.5, -0.5, 0);
    _billboardv[5] = Vector.create( 0.5,  0.5, 0);
  }

  int writeTriangle(VERTEX[] vertices, int i, ShapeAttr attr)
  in
  {
    assert(vertices.length >= i + 3);
  }
  body
  {
    Vector[3] pos;

    memcpy(pos.ptr, _trianglev.ptr, Vector.sizeof * 3);
    transform(pos, attr);
    vertices[i++] = VERTEX.create(0.5, 0, attr.color, pos[0]);
    vertices[i++] = VERTEX.create(1., 1., attr.color, pos[1]);
    vertices[i++] = VERTEX.create(1, 1.,  attr.color, pos[2]);

    return i;
  }

  int writeBillboard(VERTEX[] vertices, int i, ShapeAttr attr)
  in
  {
    assert(vertices.length >= i + 6);
  }
  body
  {
    Vector[6] pos;

    memcpy(pos.ptr, _billboardv.ptr, Vector.sizeof * 6);
    transform(pos, attr);

    vertices[i++] = VERTEX.create(0, 0, attr.color, pos[0]);
    vertices[i++] = VERTEX.create(0, 1, attr.color, pos[1]);
    vertices[i++] = VERTEX.create(1, 1, attr.color, pos[2]);
    vertices[i++] = VERTEX.create(0, 0, attr.color, pos[3]);
    vertices[i++] = VERTEX.create(1, 1, attr.color, pos[4]);
    vertices[i++] = VERTEX.create(1, 0, attr.color, pos[5]);

    return i;
  }

//  int writeBasicBillboard(VERTEX[] vertices, int i, ShapeAttr attr)
//  in
//  {
//    assert(vertices.length >= i + 6);
//  }
//  body
//  {
//    Vector[6] pos;
//
//    memcpy(pos.ptr, _billboardv.ptr, Vector.sizeof * 6);
//    transform(pos, attr);
//
//    vertices[i++] = VERTEX.create(0, 0, pos[0]);
//    vertices[i++] = VERTEX.create(0, 1, pos[1]);
//    vertices[i++] = VERTEX.create(1, 1, pos[2]);
//    vertices[i++] = VERTEX.create(0, 0, pos[3]);
//    vertices[i++] = VERTEX.create(1, 1, pos[4]);
//    vertices[i++] = VERTEX.create(1, 0, pos[5]);
//
//    return i;
//  }

  void transform(Vector[] pos, ShapeAttr attr)
  {
    Matrix translate = Matrix.translation(attr.pos.x, attr.pos.y, attr.pos.z);
    Matrix scale     = Matrix.scaling(attr.scale.x, attr.scale.y, attr.scale.z);

    // Matrix transform = scale * attr.rotation * translate;
    Matrix transform = translate * attr.rotation * scale;

    // foreach (inout p; pos)
    //   p = p * transform;

    for (int i=0; i < pos.length; ++i)
    {
      pos[i] = transform * pos[i];
    }
  }
}

//  Create an array of braid vertices in an empty vertex list
void createBraid(VERTEX)(inout VERTEX[] vertices, int c_vertices, float radius, float innerRadius, int nloops)
in
{
  assert(vertices.length == 0);
}
body
{
  float r, rr = 0;

  for (int i = 0; i < c_vertices; ++i)
  {
    r = i * (2 * PI) / c_vertices;

    VERTEX v;
    rr = nloops * r;

    v.x = radius * cos(r); 
    v.y = radius * sin(r); 
    v.z = 0;

    v.z += innerRadius * cos(rr);
    v.y += innerRadius * sin(rr);

    vertices ~= v;
  }
}

//  Cosine rose
void createRose(VERTEX)(inout VERTEX[] vertices, int c_vertices, float radius,
    int petals, bool flat = false)
in
{
  assert(vertices.length == 0);
}
body
{
  for (int i=0; i < c_vertices; ++i)
  {
    VERTEX v;

    float t = i * (2 * PI) / c_vertices;
    v.x = radius * cos(petals * t) * cos(t);
    v.y = radius * cos(petals * t) * sin(t);

    float r = ((sqrt(v.x * v.x + v.y * v.y) / radius) * 2 * PI) - PI;
    v.z = flat ? 0 : cos(r) * 0.5f * radius;

    vertices ~= v;
  }
}

//  Pyramid
void createPyramid(VERTEX)(inout VERTEX[] vertices, float width, float height)
in
{
  assert(vertices.length == 0);
}
body
{
  VERTEX[] points;

  int x[] = { width/2, width/2, -width/2, -width/2, 0 };
  int y[] = { width/2, -width/2, width/2, -width/2, 0 };
  int z[] = { 0, 0, 0, 0, height };

  for (int i = 0; i < 5; ++i)
  {
    VERTEX v;
    v.x = x[i];
    v.y = y[i];
    v.z = z[i];
    points ~= v;
  }

  vertices ~= points[0];
  vertices ~= points[1];

  vertices ~= points[1];
  vertices ~= points[2];

  vertices ~= points[2];
  vertices ~= points[3];

  vertices ~= points[3];
  vertices ~= points[0];

  vertices ~= points[0];
  vertices ~= points[4];

  vertices ~= points[1];
  vertices ~= points[4];

  vertices ~= points[2];
  vertices ~= points[4];

  vertices ~= points[3];
  vertices ~= points[4];
}

//  Cube mesh
void createCube(VERTEX)(inout VERTEX[] vertices, int c_vertices, float edge_length)
in
{
  assert(vertices.length == 0);
}
body
{
  int edge_vertices = cast(int) cbrt(c_vertices);

  for (int i=0; i < edge_vertices; ++i)
  {
    float x = (i * edge_length / edge_vertices) - edge_length / 2;

    for (int j=0; j < edge_vertices; ++j)
    {
      float y = (j * edge_length / edge_vertices) - edge_length / 2;

      for (int k=0; k < edge_vertices; ++k)
      {
        VERTEX v;

        v.x = x;
        v.y = y;
        v.z = k * edge_length / edge_vertices;

        vertices ~= v;
      }
    }
  }
}

// Sphere mesh
void createSphere(VERTEX)(inout VERTEX[] vertices, int c_vertices, float radius)
in
{
  assert(vertices.length == 0);
}
body
{
  int cube_edge_vertices = cast(int) cbrt(c_vertices);
  // width of surrounding cube
  float width = radius * 2;

  for (int i=0; i < cube_edge_vertices; ++i)
  {
    float x = (i * width / cube_edge_vertices) - width / 2;

    for (int j=0; j < cube_edge_vertices; ++j)
    {
      float y = (j * width / cube_edge_vertices) - width / 2;

      for (int k=0; k < cube_edge_vertices; ++k)
      {
        float z = (k * width / cube_edge_vertices) - width / 2;

        VERTEX v;

        v.x = x;
        v.y = y;
        v.z = z;

        float r = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);

        if (r < radius)
        {
          vertices ~= v;
        }
      }
    }
  }
}


