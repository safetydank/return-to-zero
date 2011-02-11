module core.interpolate;

import std.math;

//  Interpolation methods taken from 
//  http://local.wasp.uwa.edu.au/~pbourke/other/interpolation/

T linear_interp(T,K)(T y1, T y2, K mu)
{
  return (y1*(1-mu)+y2*mu);
}

T cos_interp(T,K)(T y1, T y2, K mu)
{
   K mu2;

   mu2 = (1-cos(mu*PI))/2;
   return (y1*(1-mu2)+y2*mu2);
}

T cubic_interp(T)(T y0, T y1, T y2, T y3, T mu)
{
   T a0,a1,a2,a3,mu2;

   mu2 = mu*mu;
   a0 = y3 - y2 - y0 + y1;
   a1 = y0 - y1 - a0;
   a2 = y2 - y0;
   a3 = y1;

   return (a0*mu*mu2+a1*mu2+a2*mu+a3);
}

