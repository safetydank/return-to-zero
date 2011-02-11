module de.math;

public import std.math;
import std.stream;

alias Vec4 Vector;
alias Vec4 float4;

struct Vec4
{
  float x = 0, y = 0, z = 0, w = 0;

  static Vec4 zero()
  {
    auto v = Vec4.create();
    return v;
  }

  static Vec4 create(float x=0., float y=0., float z=0., float w=0.)
  {
    Vec4 result;
    result.x = x;
    result.y = y;
    result.z = z;
    result.w = w;
    return result;
  }

  Vec4 opNeg() // -
  {
    return create(-x, -y, -z, -w);
  }

  bit opEquals(Vec4 f) // ==
  {
    return x == f.x && y == f.y && z == f.z && w == f.w;
  }

  Vec4 opAdd(Vec4 f) // +
  {
    return create(x + f.x, y + f.y, z + f.z, w + f.w);
  }

  Vec4 opSub(Vec4 f) // -
  {
    return create(x - f.x, y - f.y, z - f.z, w - f.w);
  }

  Vec4 opMul(float f) // *
  {
    return create(x * f, y * f, z * f, w * f);
  }

  Vec4 opDiv(float f) // /
  {
    return create(x / f, y / f, z / f, w / f);
  }

  void opAddAssign(Vec4 f) // +=
  {
    x += f.x;
    y += f.y;
    z += f.z;
    w += f.w;
  }

  void opSubAssign(Vec4 f) // -=
  {
    x -= f.x;
    y -= f.y;
    z -= f.z;
    w -= f.w;
  }

  void opMulAssign(float f) // *=
  {
    x *= f;
    y *= f;
    z *= f;
    w *= f;
  }

  void opDivAssign(float f) // /=
  {
    x /= f;
    y /= f;
    z /= f;
    w /= f;
  }

  char[] toString()
  {
    MemoryStream result = new MemoryStream();
    result.printf("{ %f %f %f %f }", cast(double)x, cast(double)y, cast(double)z, cast(double)w);
    return result.toString();
  }

  float lengthSq() { return x*x + y*y + z*z + w*w; }
  float length() { return sqrt(x*x + y*y + z*z + w*w); }

  static float dot(Vec4 a, Vec4 b) 
  {
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
  }
}

//  Generic vector functions
static float distance(V)(V a, V b)
{
  return (a - b).length;
}

static V normalize(V)(V a)
{
  return a / a.length;
}

float dot(V)(V a, V b)
{
  return V.dot(a, b);
}

float cross2(V)(V a, V b)
{
  return a.x * b.y - a.y * b.x;
}

alias cross3 cross;

V cross3(V)(V a, V b)
{
  return V.create(
      a.y * b.z - a.z * b.y,
      a.z * b.x - a.x * b.z,
      a.x * b.y - a.y * b.x
      );
}

V cross4(V)(V a, V b, V c)
{
  return V.create(
      a.y * b.z * c.w  +  b.y * c.z * a.w  +  c.y * a.z * b.w
      - c.y * b.z * a.w  -  b.y * a.z * c.w  -  a.y * c.z * b.w,

      -(a.z * b.w * c.x  +  b.z * c.w * a.x  +  c.z * a.w * b.x
        - c.z * b.w * a.x  -  b.z * a.w * c.x  -  a.z * c.w * b.x),

      a.w * b.x * c.y  +  b.w * c.x * a.y  +  c.w * a.x * b.y
      - c.w * b.x * a.y  -  b.w * a.x * c.y  -  a.w * c.x * b.y,

      -(a.x * b.y * c.z  +  b.x * c.y * a.z  +  c.x * a.y * b.z
        - c.x * b.y * a.z  -  b.x * a.y * c.z  -  a.x * c.y * b.z)
      );
}

alias Matrix float4x4;
struct Matrix
{
  float m[4][4]; 

  // Column major matrix
  //                         
  // m00 m10 m20 m30         
  // m01 m11 m21 m31         
  // m02 m12 m22 m32
  // m03 m13 m23 m33           

  float* ptr()
  {
    return cast(float*) m.ptr;
  }

  Matrix opMul(Matrix m2) // *
  {
    Matrix result = *this;
    for (int i = 0; i < 4; i++)
    {
      result.m[0][i] = m[0][i] * m2.m[0][0] + m[1][i] * m2.m[0][1] + m[2][i] * m2.m[0][2] + m[3][i] * m2.m[0][3];
      result.m[1][i] = m[0][i] * m2.m[1][0] + m[1][i] * m2.m[1][1] + m[2][i] * m2.m[1][2] + m[3][i] * m2.m[1][3];
      result.m[2][i] = m[0][i] * m2.m[2][0] + m[1][i] * m2.m[2][1] + m[2][i] * m2.m[2][2] + m[3][i] * m2.m[2][3];
      result.m[3][i] = m[0][i] * m2.m[3][0] + m[1][i] * m2.m[3][1] + m[2][i] * m2.m[3][2] + m[3][i] * m2.m[3][3];
    }
    return result;
  }

  Vec4 opMul(Vec4 v)
  {
    v.w = 1;
    Vec4 result = Vec4.create(
        v.x * m[0][0] + v.y * m[1][0] + v.z * m[2][0] + v.w * m[3][0],
        v.x * m[0][1] + v.y * m[1][1] + v.z * m[2][1] + v.w * m[3][1],
        v.x * m[0][2] + v.y * m[1][2] + v.z * m[2][2] + v.w * m[3][2],
        v.x * m[0][3] + v.y * m[1][3] + v.z * m[2][3] + v.w * m[3][3]
        );
    v.w = 0;
    result.w = 0;
    return result;
  }

  void opMulAssign(Matrix m2) // *=
  {
    Matrix result = *this;
    *this = result * m2;
  }

  static Matrix identity()
  {
    Matrix result;
    for (int i = 0; i < 4; i++) result.m[i][] = 0.0;
    for (int i = 0; i < 4; i++) result.m[i][i] = 1.0;
    return result;
  }

  static Matrix zero()
  {
    Matrix result;
    for (int i = 0; i < 4; i++)
      for (int j = 0; j < 4; j++) result.m[i][j] = 0;

    return result;
  }

  static Matrix translation(float x, float y, float z)
  {
    Matrix result = identity;
    result.m[3][0] = x;
    result.m[3][1] = y;
    result.m[3][2] = z;
    return result;
  }

  static Matrix scaling(float sx, float sy, float sz)
  {
    Matrix result = identity;
    result.m[0][0] = sx;
    result.m[1][1] = sy;
    result.m[2][2] = sz;
    return result;
  }

  static Matrix rotationX(float radian)
  {
    Matrix result = identity;
    result.m[1][1] = cos(radian);
    result.m[1][2] = sin(radian);
    result.m[2][1] = -sin(radian);
    result.m[2][2] = cos(radian);
    return result;
  }

  static Matrix rotationY(float radian)
  {
    Matrix result = identity;
    result.m[0][0] = cos(radian);
    result.m[0][2] = -sin(radian);
    result.m[2][0] = sin(radian);
    result.m[2][2] = cos(radian);
    return result;
  }

  static Matrix rotationZ(float radian)
  {
    Matrix result = identity;
    result.m[0][0] = cos(radian);
    result.m[0][1] = sin(radian);
    result.m[1][0] = -sin(radian);
    result.m[1][1] = cos(radian);
    return result;
  }

  static Matrix lookAtLH(
      float px, float py, float pz, float ax, float ay, float az, float ux, float uy, float uz)
  {
    Vec4 position = Vec4.create(px, py, pz);
    Vec4 lookAtPoint = Vec4.create(ax, ay, az);
    Vec4 upDirection = Vec4.create(ux, uy, uz);
    Vec4 zaxis = normalize(lookAtPoint - position);
    Vec4 xaxis = normalize(cross3(upDirection, zaxis));
    Vec4 yaxis = cross3(zaxis, xaxis);
    Matrix result;
    result.m[0][0] = xaxis.x;
    result.m[0][1] = yaxis.x;
    result.m[0][2] = zaxis.x;
    result.m[0][3] = 0;
                  
    result.m[1][0] = xaxis.y;
    result.m[1][1] = yaxis.y;
    result.m[1][2] = zaxis.y;
    result.m[1][3] = 0;
                  
    result.m[2][0] = xaxis.z;
    result.m[2][1] = yaxis.z;
    result.m[2][2] = zaxis.z;
    result.m[2][3] = 0;
                  
    result.m[3][0] = -dot(xaxis, position);
    result.m[3][1] = -dot(yaxis, position);
    result.m[3][2] = -dot(zaxis, position);
    result.m[3][3] = 1;
    return result;
  }

  static Matrix lookAtRH(
      float px, float py, float pz, float ax, float ay, float az, float ux, float uy, float uz)
  {
    Vec4 position = Vec4.create(px, py, pz);
    Vec4 lookAtPoint = Vec4.create(ax, ay, az);
    Vec4 upDirection = Vec4.create(ux, uy, uz);
    Vec4 zaxis = normalize(position - lookAtPoint); //
    Vec4 xaxis = normalize(cross3(upDirection, zaxis));
    Vec4 yaxis = cross3(zaxis, xaxis);
    Matrix result;
    result.m[0][0] = xaxis.x;
    result.m[0][1] = yaxis.x;
    result.m[0][2] = zaxis.x;
    result.m[0][3] = 0;
                  
    result.m[1][0] = xaxis.y;
    result.m[1][1] = yaxis.y;
    result.m[1][2] = zaxis.y;
    result.m[1][3] = 0;
                  
    result.m[2][0] = xaxis.z;
    result.m[2][1] = yaxis.z;
    result.m[2][2] = zaxis.z;
    result.m[2][3] = 0;
                  
    result.m[3][0] = -dot(xaxis, position);
    result.m[3][1] = -dot(yaxis, position);
    result.m[3][2] = -dot(zaxis, position);
    result.m[3][3] = 1;
    return result;
  }

  static Matrix perspectiveFovLH(
      float fieldOfViewY, float aspectRatio, float nearPlaneZ, float farPlaneZ)
  {
    float cot(float a) { return 1 / tan(a); }
    Matrix result = zero;
    float h = cot(fieldOfViewY / 2);
    result.m[0][0] = h / aspectRatio;
    result.m[1][1] = h;
    result.m[2][2] = farPlaneZ / (farPlaneZ - nearPlaneZ);
    result.m[2][3] = -nearPlaneZ * farPlaneZ / (farPlaneZ - nearPlaneZ);
    result.m[3][2] = 1;
    return result;
  }

  static Matrix perspectiveFovRH(
      float fieldOfViewY, float aspectRatio, float nearPlaneZ, float farPlaneZ)
  {
    float cot(float a) { return 1 / tan(a); }
    Matrix result = zero;
    float h = cot(fieldOfViewY / 2);
    result.m[0][0] = h / aspectRatio;
    result.m[1][1] = h;
    result.m[2][2] = farPlaneZ / (nearPlaneZ - farPlaneZ); //
    result.m[2][3] = nearPlaneZ * farPlaneZ / (nearPlaneZ - farPlaneZ); //
    result.m[3][2] = -1; //
    return result;
  }

  char[] toString()
  {
    MemoryStream result = new MemoryStream();
    result.printf("{\n");
    for (int i = 0; i < 4; i++)
    {
      result.printf("  %f %f %f %f\n", cast(double)m[i][0], cast(double)m[i][1], cast(double)m[i][2], cast(double)m[i][3]);
    }
    result.printf("}");
    return result.toString();
  }
}

Matrix transpose(Matrix m)
{
  Matrix result = Matrix.zero;
  result.m[0][0] = m.m[0][0];
  result.m[0][1] = m.m[1][0];
  result.m[0][2] = m.m[2][0];
  result.m[0][3] = m.m[3][0];
  result.m[1][0] = m.m[0][1];
  result.m[1][1] = m.m[1][1];
  result.m[1][2] = m.m[2][1];
  result.m[1][3] = m.m[3][1];
  result.m[2][0] = m.m[0][2];
  result.m[2][1] = m.m[1][2];
  result.m[2][2] = m.m[2][2];
  result.m[2][3] = m.m[3][2];
  result.m[3][0] = m.m[0][3];
  result.m[3][1] = m.m[1][3];
  result.m[3][2] = m.m[2][3];
  result.m[3][3] = m.m[2][3];
  return result;
}

Matrix inverse(Matrix m)
{
  Matrix result = Matrix.zero;
  result.m[0][0] = m.m[0][0];
  result.m[1][0] = m.m[0][1];
  result.m[2][0] = m.m[0][2];
  result.m[0][1] = m.m[1][0];
  result.m[1][1] = m.m[1][1];
  result.m[2][1] = m.m[1][2];
  result.m[0][2] = m.m[2][0];
  result.m[1][2] = m.m[2][1];
  result.m[2][2] = m.m[2][2];
  result.m[0][3] = -(m.m[0][0] * m.m[0][3] + m.m[0][1] * m.m[1][3] + m.m[0][2] * m.m[2][3]);
  result.m[1][3] = -(m.m[1][0] * m.m[0][3] + m.m[1][1] * m.m[1][3] + m.m[1][2] * m.m[2][3]);
  result.m[2][3] = -(m.m[2][0] * m.m[0][3] + m.m[2][1] * m.m[1][3] + m.m[2][2] * m.m[2][3]);
  result.m[3][3] = 1;
  return result;
}

Matrix createMatrixFromQuaternion(Vec4 quaternion)
{
  float x = quaternion.x;
  float y = quaternion.y;
  float z = quaternion.z;
  float w = quaternion.w;
  Matrix result = Matrix.identity;
  result.m[0][0] = 1 - 2 * (y * y + z * z);
  result.m[1][1] = 1 - 2 * (x * x + z * z);
  result.m[2][2] = 1 - 2 * (x * x + y * y);
  result.m[1][0] = 2 * (x * y + z * w);
  result.m[2][0] = 2 * (x * z - y * w);
  result.m[0][1] = 2 * (x * y - z * w);
  result.m[2][1] = 2 * (y * z + x * w);
  result.m[0][2] = 2 * (x * z + y * w);
  result.m[1][2] = 2 * (y * z - x * w);
  return result;
}

Vec4 createSlerpQuaternion(Vector quaternion0, Vector quaternion1, float t)
{
  const float DELTA = 1e-6;
  float cosom = dot(quaternion0, quaternion1);
  if (cosom < 0)
  {
    cosom = -cosom;
    quaternion1 = -quaternion1;
  }
  float scale0, scale1;
  if (1 - cosom > DELTA)
  {
    float omega = acos(cosom);
    float sinom = sin(omega);
    scale0 = sin((1 - t) * omega) / sinom;
    scale1 = sin(t * omega) / sinom;
  }
  else
  {
    scale0 = 1 - t;
    scale1 = t;
  }
  return quaternion0 * scale0 + quaternion1 * scale1;
}

bit triangleIntersectRay(
    Vec4 t0, Vector t1, Vector t2, Vector rayPosition, Vector rayDirection)
{
  float distance;
  return triangleIntersectRay2(t0, t1, t2, rayPosition, rayDirection, distance);
}

float distanceOfTriangleAndRay(
    Vec4 t0, Vector t1, Vector t2, Vector rayPosition, Vector rayDirection)
in
{
  assert(triangleIntersectRay(t0, t1, t2, rayPosition, rayDirection));
}
body
{
  float distance;
  triangleIntersectRay2(t0, t1, t2, rayPosition, rayDirection, distance);
  return distance;
}

private bit triangleIntersectRay2(
    Vec4 t0, Vector t1, Vector t2, Vector rayPosition, Vector rayDirection,
    inout float distance)
{
  const float EPSILON = 0.000001;
  Vec4 edge1 = t1 - t0;
  Vec4 edge2 = t2 - t0;
  Vec4 pvec = cross3(rayDirection, edge2);
  float det = dot(edge1, pvec);
  if (det > -EPSILON && det < EPSILON) return false;
  float inv_det = 1.0 / det;
  Vec4 tvec = rayPosition - t0;
  float u = dot(tvec, pvec) * inv_det;
  if (u < 0.0 || u > 1.0) return false;
  Vec4 qvec = cross3(tvec, edge1);
  float v = dot(rayDirection, qvec) * inv_det;
  if (v < 0.0 || u + v > 1.0) return false;
  distance = dot(edge2, qvec) * inv_det;
  return true;
}

float distanceOfPointAndLine(Vec4 p, Vector l0, Vector l1)
{
  return (cross3(l1 - l0, p - l0)).length / (l1 - l0).length;
}

float distanceOfPointAndLineSegment(Vec4 p, Vector ls0, Vector ls1)
{
  return lineSegmentToPoint(ls0, ls1, p).length;
}

Vec4 lineSegmentToPoint(Vector ls0, Vector ls1, Vector p)
{
  if (dot(p - ls0, ls0 - ls1) > 0.0) return p - ls0;
  else if (dot(p - ls1, ls1 - ls0) > 0.0) return p - ls1;
  return normalize(cross3(cross3(ls1 - ls0, p - ls0), ls1 - ls0))
    * distanceOfPointAndLine(p, ls0, ls1);
}

unittest
{
  Vec4 f;
  f = -Vec4.create(1, 2);
  assert(-1 == f.x && -2 == f.y);
  assert(Vec4.create(-1, -2) == f);
  f = Vec4.create(1, 2);
  assert(Vec4.create(2, 4) == f + f);
  assert(Vec4.create(0, 0) == f - f);
  assert(Vec4.create(3, 6) == f * 3);
  assert(Vec4.create(3, 6) == 3 * f);
  assert(Vec4.create(0.5, 1) == f / 2);
  f += Vec4.create(1, 2);
  assert(Vec4.create(2, 4) == f);
  f -= Vec4.create(1, 2);
  assert(Vec4.create(1, 2) == f);
  f *= 3;
  assert(Vec4.create(3, 6) == f);
  f /= 3;
  assert(Vec4.create(1, 2) == f);
  assert(5 == (Vec4.create(3, 4)).length);
  assert(5 == distance(Vec4.create(1, 1), Vector.create(4, 5)));
  bit nearlyOne(float f) { return fabs(f - 1) < 0.00000001; }
  assert(nearlyOne(normalize(Vec4.create(3, 4)).length));
  assert(0 == dot(Vec4.create(1, 0), Vector.create(0, 1)));
  assert(0 == cross2(Vec4.create(1, 0), Vector.create(-1, 0)));
  printf(".");
}

unittest 
{
  Vec4 f;
  f = -Vec4.create(1, 2, 3);
  assert(-1 == f.x && -2 == f.y && -3 == f.z);
  assert(Vec4.create(-1, -2, -3) == f);
  f = Vec4.create(1, 2, 3);
  assert(Vec4.create(2, 4, 6) == f + f);
  assert(Vec4.create(0, 0, 0) == f - f);
  assert(Vec4.create(3, 6, 9) == f * 3);
  assert(Vec4.create(0.5, 1, 1.5) == f / 2);
  f += Vec4.create(1, 2, 3);
  assert(Vec4.create(2, 4, 6) == f);
  f -= Vec4.create(1, 2, 3);
  assert(Vec4.create(1, 2, 3) == f);
  f *= 3;
  assert(Vec4.create(3, 6, 9) == f);
  f /= 3;
  assert(Vec4.create(1, 2, 3) == f);
  bit nearly(float a, float b) { return fabs(a - b) < 0.000001; }
  assert(nearly(sqrt(3.0), Vec4.create(1, 1, 1).length));
  assert(nearly(sqrt(3.0),
        distance(Vec4.create(1, 1, 1), Vector.create(2, 2, 2))
        ));
  assert(nearly(1.0, normalize(Vec4.create(1, 2, 3)).length));
  assert(0 == dot(Vec4.create(1, 0, 0), Vector.create(0, 1, 0)));
  assert(Vec4.create(0, 0, 0) == cross(Vector.create(1, 0, 0), Vector.create(-1, 0, 0)));
  printf(".");
}

unittest
{
  assert(16 == Vec4.sizeof);
  Vec4 f;
  f = -Vec4.create(1, 2, 3, 4);
  assert(-1 == f.x && -2 == f.y && -3 == f.z && -4 == f.w);
  assert(Vec4.create(-1, -2, -3, -4) == f);
  f = Vec4.create(1, 2, 3, 4);
  assert(Vec4.create(2, 4, 6, 8) == f + f);
  assert(Vec4.create(0, 0, 0, 0) == f - f);
  assert(Vec4.create(3, 6, 9, 12) == f * 3);
  assert(Vec4.create(0.5, 1, 1.5, 2) == f / 2);
  f += Vec4.create(1, 2, 3, 4);
  assert(Vec4.create(2, 4, 6, 8) == f);
  f -= Vec4.create(1, 2, 3, 4);
  assert(Vec4.create(1, 2, 3, 4) == f);
  f *= 3;
  assert(Vec4.create(3, 6, 9, 12) == f);
  f /= 3;
  assert(Vec4.create(1, 2, 3, 4) == f);
  bit nearly(float a, float b) { return fabs(a - b) < 0.000001; }
  assert(nearly(sqrt(4.0), Vec4.create(1, 1, 1, 1).length));
  assert(nearly(sqrt(4.0),
        distance(Vec4.create(1, 1, 1, 1), Vector.create(2, 2, 2, 2))
        ));
  assert(nearly(1.0, normalize(Vec4.create(1, 2, 3, 4)).length));
  assert(0 == dot(Vec4.create(1, 0, 0, 0), Vector.create(0, 1, 0, 0)));
  assert(Vec4.create(0, 0, 0, 0) == cross(
        Vec4.create(1, 0, 0, 0),
        Vec4.create(-1, 0, 0, 0),
        Vec4.create(0, 0, 0, 0)
        ));
  printf(".");
}

float heading(float x, float y)
{
  float t = 0;

  if (y == 0)
    t = (x < 0) ? -PI/2 : PI/2;
  else
  {
    t = atan(x / y);
    if (y < 0)
      t = t + PI;
  }

  if (t < 0) t += 2 * PI;

  return t;
}

const float RADIANS_TO_DEGREES = 180 / PI;
const float DEGREES_TO_RADIANS = PI / 180;
T rad2deg(T)(T rad) { return rad * RADIANS_TO_DEGREES; }
T deg2rad(T)(T deg) { return deg * DEGREES_TO_RADIANS; }

