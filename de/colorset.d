module de.colorset;

import core.interpolate;
import de.math;

class ColorSet
{
  Vector[] _colors;
  int _i_color;

  //  Active color
  Vector _color;
  public Vector color() { return _color; }

  float _cycleTime;
  float _elapsed;

  public this(float cycleTime, float r, float g, float b, float a)
  {
    this(cycleTime, Vector.create(r, g, b, a));
  }

  public this(float cycleTime, Vector color)
  {
    _elapsed = 0;
    _cycleTime = cycleTime;
    _colors ~= color;
  }

  public void add(float r, float g, float b, float a = 1.0f)
  {
    add(Vector.create(r, g, b, a));
  }

  public void add(Vector v)
  {
    _colors ~= v;
  }

  public void move(float elapsed)
  {
    if (_colors.length == 1)
    {
      _color = _colors[0];
      return;
    }

    _elapsed += elapsed;
    float dt = _elapsed / _cycleTime;
    float ratio = dt - cast(int) dt;

    // _color = _colors[_i_color] + ratio * (nextColor - _colors[_i_color]);
    _color = cos_interp(_colors[_i_color], nextColor, dt);

    dt -= ratio;

    if (_elapsed > _cycleTime)
    {
      _elapsed = 0;
      _i_color = nextColorIndex();
    }
  }

  Vector nextColor()
  {
    return _colors[nextColorIndex()];
  }

  int nextColorIndex()
  {
    if (_i_color + 1 >= _colors.length)
      return 0;
    else
      return _i_color + 1;
  }
}
