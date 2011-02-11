module de.collision;

import std.string;
import core.logger;

import de.math;

//  Bounding circle, storing current and previous positions
struct BoundingCircle
{
  float radius;
  Vector pos;
  Vector prev;

  static BoundingCircle create(float radius, Vector pos, Vector prev)
  {
    BoundingCircle c;
    c.pos = pos;
    c.prev = prev;
    c.radius = radius;

    return c;
  }

  char[] toString()
  {
    return 
      format("pos %f,%f prev %f %f r %f", pos.x, pos.y, prev.x, prev.y, radius);
  }
}

//  Check if two circles have collided
bool collided(BoundingCircle A, BoundingCircle B, bool intersectOnly = false)
{
  // calculate relative velocity and position
  Vector Av = A.pos - A.prev;
  Vector Bv = B.pos - B.prev;
  Vector dv = Bv - Av;
  Vector dp = B.pos - A.pos;
  // Logger.instance.message(format("DV: %f,%f DP: %f,%f", dv.x, dv.y, dp.x, dp.y));

  // check if circles are already intersecting
  float r = A.radius + B.radius;
  float pp = (dp.x*dp.x + dp.y*dp.y) - r*r;
  if (pp < 0) 
  { 
    // Logger.instance.message("intersecting"); 
    return true; 
  }
  else if (intersectOnly)
  {
    return false;
  }

  // // check if the circles are moving away from each other and hence can't
  // // collide
  float pv = dp.x*dv.x + dp.y*dv.y;
  if (pv >= 0) return false;

  // // check if the circles can reach each other between the frames
  float vv = dv.x*dv.x + dv.y*dv.y;
  if ((pv + vv) <= 0 && (vv + 2*pv + pp) >= 0) return false;

  //float tmin = -pv / vv;
  //if (pp + pv*tmin > 0)
  float D = pv * pv - pp * vv;
  if (D > 0)
  {
    // Logger.instance.message(format("Between frames at time %f", tmin));
    return true;
  }

  return false;
}

