module de.camera;

import de.math;
import derelict.opengl.gl;

class Camera
{
//  Matrix _view;

  Vector _right;
  Vector _up;
  Vector _look;

  public Vector pos;

  public this()
  {
  }

  public this(Vector pos, Vector target, Vector up)
  {
    lookAt(pos, target, up);
  }

  public void setCamera(Camera c)
  {
    this.pos = c.pos;
    this._right = c._right;
    this._up = c._up;
    this._look = c._look;
  }

  public void lookAt(Vector pos, Vector target)
  {
    lookAt(pos, target, Vector.create(0, 1., 0));
  }

  public void lookAt(Vector pos, Vector target, Vector up)
  {
    this.pos = pos;
    _look = normalize(target - pos);
    _up = up;
  }

  public void update(float elapsed)
  {
  }

  public void setView()
  {
    updateVectors();
    Vector target = _look + pos;
    Matrix look = Matrix.lookAtRH(pos.x, pos.y, pos.z, target.x, target.y, target.z, 
        0, 1.0, 0);
    glMatrixMode(GL_MODELVIEW);
    glLoadMatrixf(look.ptr);
  }

  public void rotateX(float rad)
  {
    Matrix rotX = Matrix.rotationX(rad);
    rotate(rotX);
  }

  public void rotateY(float rad)
  {
    Matrix rotY = Matrix.rotationY(rad);
    rotate(rotY);
  }

  public void rotateZ(float rad)
  {
    Matrix rotZ = Matrix.rotationZ(rad);
    rotate(rotZ);
  }

  public void rotate(Matrix mat)
  {
    _up = mat * _up;
    _look = mat * _look;
    updateVectors();
  }

  public void translate(Vector v)
  {
    pos += v;
  }

  protected:

  void updateVectors()
  {
    _look = normalize(_look);

    _up   = cross4(_up, _look, _right);
    _up   = normalize(_up);

    _right = cross3(_up, _look);
    _right = normalize(_right);
  }
}
