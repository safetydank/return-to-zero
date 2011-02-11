module core.util;

extern (C) void* memcpy(void* dest, void* src, size_t count);

void swap(T)(inout T a, inout T b)
{
  T tmp;
  tmp = a;
  a = b;
  b = tmp;
}

T abs(T)(T val)
{
  if (val < 0)
    return -val;

  return val;
}

T max(T)(T a, T b)
{
  if (a > b) return a;
  return b;
}

T min(T)(T a, T b)
{
  if (a < b) return a;
  return b;
}

bool inRange(T)(T x, T min, T max)
{
  return (x >= min && x <= max);
}

bool clampToRange(T)(inout T x, T min, T max)
{
  bool clamp = false;

  if (x < min)
  {
    x = min;
    return true;
  }

  if (x > max)
  {
    x = max;
    return true;
  }

  return false;
}

