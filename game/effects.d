module game.effects;

import de.math;
import game.field;

public static Effect[] GameOver()
{
  Effect[] e;

  Effect rose = Effect.createDefault;
  rose.method = Effect_t.ROSE;
  for (int i = 0; i < 5; ++i)
  {
    Effect newRose = rose;
    newRose.clockDivider = 0.2 + (i/5)*0.8;
    newRose.colorset = i % 4;
    newRose.beginTime = i * 4;
    newRose.iterations = 1;
    newRose.iterRotation = 20;
    newRose.flipRotation = true;
    e ~= newRose;
  }

  auto chains = MyFatGoldChains();
  foreach (c; chains)
  {
    e ~= c;
  }

  return e;
}

public static Effect[] MyFatGoldChains()
{
  Effect[] e;

  Effect braid = Effect.createDefault;
  braid.colorset = 0;
  braid.scaleClock = 10.0;
  braid.translate = Vector.create(5.0, 5.0, 5.0);

  Effect braid2 = braid;
  braid2.translate = Vector.create(-5.0, -5.0, 5.0);
  braid2.beginTime = 2.5;

  Effect braid3 = braid;
  braid3.translate = Vector.create(-5.0, 5.0, 5.0);
  braid3.beginTime = 5;

  Effect braid4 = braid;
  braid4.translate = Vector.create( 5.0, -5.0, 5.0);
  braid4.beginTime = 7.5;

  Effect braid5 = braid;
  braid5.translate = Vector.zero;
  braid5.scaleClock = 10.0;
  braid5.colorset = 4;
  braid5.clockDivider = 0.2;

  e ~= braid;
  e ~= braid2;
  e ~= braid3;
  e ~= braid4;
  e ~= braid5;
  return e;
}

public static Effect[] GoldBraids()
{
  Effect[] e;

  Effect braid = Effect.createDefault;
  braid.translate = Vector.create(5.0, 5.0, 5.0);

  Effect braidCopy = braid;
  braidCopy.translate = Vector.create(-5.0, -5.0, -5.0);
  braidCopy.beginTime = 4.0;

  e ~= braid;
  e ~= braidCopy;
  return e;
}

public static Effect[] BlueSinCubePlusRose()
{
  Effect[] e;

  Effect sinCube = Effect.createDefault();
  sinCube.method = Effect_t.CUBE;
  sinCube.scale = 8.0;
  sinCube.flipRotation = true;
  sinCube.iterRotation = 10;
  sinCube.colorset = 6;
  sinCube.sinScale = true;
  sinCube.translate = Vector.create(0.0, 0.0, 10.0);

  Effect greenRose = Effect.createDefault();
  greenRose.method = Effect_t.ROSE;
  greenRose.colorset = 2;
  greenRose.iterations = 2;
  greenRose.frameFrequency = 5;
  greenRose.translate = Vector.create(-5.0, -5.0, 8.0);

  e ~= sinCube;
  e ~= greenRose;
  return e;
}
public static Effect[] SwirlyRedLines()
{
  Effect[] e;

  Effect rose1 = Effect.createDefault();
  rose1.method = Effect_t.ROSE;
  rose1.scale = 10.0;
  rose1.flipRotation = true;
  //rose1.iterRotation = 10;
  rose1.colorset = 1;
  rose1.sinScale = true;
  rose1.translate = Vector.create(-1, -1, 20);

  Effect rose2 = rose1;
  rose2.translate = Vector.create(1, 1, 20);
  rose2.beginTime = 2.0;

  Effect rose3 = rose1;
  rose3.translate = Vector.create(-2, 2, 20);
  rose3.beginTime = 4.0;

  Effect rose4 = rose1;
  rose4.translate = Vector.create(3, -3, 20);
  rose4.beginTime = 6.0;

  Effect rose5 = rose1;
  rose5.translate = Vector.create(4, 4, 20);
  rose5.beginTime = 4.0;

  Effect rose6 = rose1;
  rose6.translate = Vector.create(-5, -5, 20);
  rose6.beginTime = 6.0;

  Effect rose7 = rose1;
  rose7.translate = Vector.create(-4, 4, 20);
  rose7.beginTime = 4.0;

  Effect rose8 = rose1;
  rose8.translate = Vector.create(5, -5, 20);
  rose8.beginTime = 6.0;

  e ~= rose1;
  e ~= rose2;
  e ~= rose3;
  e ~= rose4;
  e ~= rose5;
  e ~= rose6;
  e ~= rose7;
  e ~= rose8;
  return e;
}

public static Effect[] SwirlyYellowLines()
{
  Effect[] e;

  Effect rose1 = Effect.createDefault();
  rose1.method = Effect_t.ROSE;
  rose1.scale = 10.0;
  rose1.flipRotation = true;
  //rose1.iterRotation = 10;
  rose1.colorset = 20;
  rose1.sinScale = true;
  rose1.translate = Vector.create(-1, -1, 20);

  Effect braid = Effect.createDefault();
  braid.method = Effect_t.BRAID;
  braid.scale = 50.0;
  braid.flipRotation = true;
  braid.iterRotation = 10;
  braid.colorset = 10;
  braid.scaleModFactor = 0.6;
  braid.disableAdditive = false;
  braid.translate = Vector.create(0, 0, 0);
  braid.beginTime = 0;

  Effect braid2 = braid;
  braid2.colorset = 20;
  braid2.beginTime = 2.5;

  Effect rose2 = rose1;
  rose2.translate = Vector.create(1, 1, 20);
  rose2.beginTime = 0.5;

  Effect rose3 = rose1;
  rose3.translate = Vector.create(-2, 2, 20);
  rose3.beginTime = 1.0;

  Effect rose4 = rose1;
  rose4.translate = Vector.create(3, -3, 20);
  rose4.beginTime = 1.5;

  Effect rose5 = rose1;
  rose5.translate = Vector.create(4, 4, 20);
  rose5.beginTime = 4.0;

  Effect rose6 = rose1;
  rose6.translate = Vector.create(-5, -5, 20);
  rose6.beginTime = 4.5;

  Effect rose7 = rose1;
  rose7.translate = Vector.create(-4, 4, 20);
  rose7.beginTime = 5.0;

  Effect rose8 = rose1;
  rose8.translate = Vector.create(5, -5, 20);
  rose8.beginTime = 5.5;

  e ~= rose1;
  e ~= rose2;
  e ~= rose3;
  e ~= rose4;
  e ~= rose5;
  e ~= rose6;
  e ~= rose7;
  e ~= rose8;
  e ~= braid;
  e ~= braid2;
  return e;
}

public static Effect[] GreenPurpleMixed()
{
  Effect[] e;

  Effect darkcube1 = Effect.createDefault();
  darkcube1.method = Effect_t.BRAID;
  darkcube1.scale = 25.0;
  darkcube1.flipRotation = true;
  darkcube1.iterRotation = 10;
  darkcube1.colorset = 11;
  darkcube1.sinScale = false;
  darkcube1.translate = Vector.create(0, 0, 0);
  darkcube1.scaleModFactor = 0.5;
  darkcube1.disableAdditive = true;

  Effect brightcube1 = Effect.createDefault;
  brightcube1.method = Effect_t.CUBE;
  brightcube1.scale = 15.0;
  brightcube1.iterRotation = 10;
  brightcube1.sinScale = false;
  brightcube1.translate = Vector.create(-8, -5, 0);
  brightcube1.beginTime = 0.0;
  brightcube1.disableAdditive = true;
  brightcube1.colorset = 10;

  Effect brightcube2 = brightcube1;
  brightcube2.translate = Vector.create(8, 5, 0);

  Effect greencube1 = Effect.createDefault();
  greencube1.method = Effect_t.CUBE;
  greencube1.scale = 10.0;
  greencube1.flipRotation = true;
  greencube1.iterRotation = 10;
  greencube1.colorset = 8;
  greencube1.sinScale = false;
  greencube1.translate = Vector.create(-10, 8, 2);
  greencube1.beginTime = 2.0;

  Effect greencube2 = greencube1;
  greencube1.translate = Vector.create(10, -8, -2);

  e ~= darkcube1;
  e ~= brightcube1;
  e ~= brightcube2;
  e ~= greencube1;
  e ~= greencube2;
  return e;
}

public static Effect[] OceanBlueRandom()
{
  Effect[] e;

  // they're not all spheres! :)

  Effect sphere1 = Effect.createDefault;
  sphere1.method = Effect_t.SPHERE;
  sphere1.translate = Vector.create(8.0, 5.0, 0);
  sphere1.colorset = 12;
  sphere1.scale = 100.0;
  sphere1.disableAdditive = true;
  sphere1.scaleModFactor = 0.7;

  Effect sphere2 = sphere1;
  sphere2.method = Effect_t.CUBE;
  sphere2.translate = Vector.create(-8.0, -5.0, 0);
  sphere2.beginTime = 1.0;
  sphere2.colorset = 13;
  sphere2.scale = 25.0;
  sphere2.sinScale = true;

  Effect sphere3 = sphere1;
  sphere3.translate = Vector.create(10.0, -5.0, 0);
  sphere3.beginTime = 4.0;
  sphere3.colorset = 14;

  Effect sphere4 = sphere1;
  sphere4.method = Effect_t.BRAID;
  sphere4.translate = Vector.create(-10.0, 5.0, 0);
  sphere4.beginTime = 6.0;
  sphere4.colorset = 13;

  e ~= sphere1;
  e ~= sphere2;
  e ~= sphere3;
  e ~= sphere4;
  return e;
}

public static Effect[] TrippyRoses()
{
  Effect[] e;

  Effect rose1 = Effect.createDefault();
  rose1.method = Effect_t.ROSE;
  rose1.scale = 1.5;
  rose1.flipRotation = true;
  rose1.colorset = 16;
  rose1.sinScale = true;
  rose1.translate = Vector.create(-7, -3, 0);
  rose1.beginTime = 0.5;
  rose1.disableAdditive = true;

  Effect rose2 = rose1;
  rose2.translate = Vector.create(8, 4, 0);
  rose2.beginTime = 1.5;

  Effect rose3 = rose1;
  rose3.translate = Vector.create(-5, 5, 0);
  rose3.beginTime = 1.0;

  Effect rose4 = rose1;
  rose4.translate = Vector.create(3, -2, 0);
  rose4.beginTime = 2.0;

  Effect rose5 = rose1;
  rose5.colorset = 15;
  rose5.scale = 20.0;
  rose5.translate = Vector.create(0, 0, 0);
  rose5.beginTime = 0;
  rose5.disableAdditive = false;

  Effect rose6 = rose1;
  rose6.translate = Vector.create(-5, -5, 20);
  rose6.beginTime = 6.0;

  Effect rose7 = rose1;
  rose7.translate = Vector.create(-4, 4, 20);
  rose7.beginTime = 4.0;

  Effect rose8 = rose1;
  rose8.translate = Vector.create(5, -5, 20);
  rose8.beginTime = 6.0;

  e ~= rose1;
  e ~= rose2;
  e ~= rose3;
  e ~= rose4;
  e ~= rose5;
  e ~= rose6;
  e ~= rose7;
  e ~= rose8;
  return e;
}

public static Effect[] GreenRandom()
{
  Effect[] e;

  // object names are inaccurate

  Effect darkcube1 = Effect.createDefault();
  darkcube1.method = Effect_t.BRAID;
  darkcube1.scale = 25.0;
  darkcube1.flipRotation = true;
  darkcube1.iterRotation = 10;
  darkcube1.colorset = 17;
  darkcube1.scaleModFactor = 0.5;
  darkcube1.disableAdditive = true;
  darkcube1.translate = Vector.create(0, 0, 0);
  darkcube1.beginTime = 2.5;

  /*
  Effect rose1 = darkcube1;
  rose1.method = Effect_t.ROSE;
  rose1.scale = 20;
  rose1.flipRotation = true;
  rose1.colorset = 17;
  rose1.sinScale = false;
  rose1.translate = Vector.create(0, 0, 0);
  rose1.disableAdditive = true;
  rose1.beginTime = 0.0;
  */

  Effect brightcube1 = Effect.createDefault;
  brightcube1.method = Effect_t.CUBE;
  brightcube1.scale = 15.0;
  brightcube1.iterRotation = 10;
  brightcube1.disableAdditive = true;
  brightcube1.colorset = 17;
  brightcube1.translate = Vector.create(-8, -5, 0);
  brightcube1.beginTime = 0.0;
  brightcube1.disableAdditive = true;

  Effect brightcube2 = brightcube1;
  brightcube2.translate = Vector.create(8, 5, 0);

  Effect greencube1 = Effect.createDefault();
  greencube1.method = Effect_t.CUBE;
  greencube1.scale = 10.0;
  greencube1.flipRotation = true;
  greencube1.iterRotation = 10;
  greencube1.colorset = 17;
  greencube1.translate = Vector.create(-10, 8, 2);
  greencube1.beginTime = 2.0;
  greencube1.disableAdditive = true;

  Effect greencube2 = greencube1;
  greencube1.translate = Vector.create(10, -8, -2);

  e ~= darkcube1;
  e ~= brightcube1;
  e ~= brightcube2;
  e ~= greencube1;
  e ~= greencube2;
  //e ~= rose1;
  return e;
}

public static Effect[] GreenAquaRandom()
{
  Effect[] e;

  // object names are inaccurate

  Effect darkcube1 = Effect.createDefault();
  darkcube1.method = Effect_t.BRAID;
  darkcube1.scale = 25.0;
  darkcube1.flipRotation = true;
  darkcube1.iterRotation = 10;
  darkcube1.colorset = 19;
  darkcube1.scaleModFactor = 0.5;
  darkcube1.disableAdditive = false;
  darkcube1.translate = Vector.create(0, 0, 0);
  darkcube1.beginTime = 2.5;

  Effect rose1 = darkcube1;
  rose1.method = Effect_t.ROSE;
  rose1.scale = 20;
  rose1.flipRotation = true;
  rose1.colorset = 17;
  rose1.sinScale = false;
  rose1.translate = Vector.create(0, 0, 0);
  rose1.disableAdditive = true;
  rose1.beginTime = 0.0;

  Effect brightcube1 = Effect.createDefault;
  brightcube1.method = Effect_t.CUBE;
  brightcube1.scale = 15.0;
  brightcube1.iterRotation = 10;
  brightcube1.disableAdditive = true;
  brightcube1.translate = Vector.create(-8, -5, 0);
  brightcube1.beginTime = 0.0;
  brightcube1.colorset = 17;
  brightcube1.disableAdditive = true;

  Effect brightcube2 = brightcube1;
  brightcube2.translate = Vector.create(8, 5, 0);

  Effect greencube1 = Effect.createDefault();
  greencube1.method = Effect_t.CUBE;
  greencube1.scale = 10.0;
  greencube1.flipRotation = true;
  greencube1.iterRotation = 10;
  greencube1.translate = Vector.create(-10, 8, 2);
  greencube1.beginTime = 2.0;
  greencube1.colorset = 18;
  greencube1.disableAdditive = false;

  Effect greencube2 = greencube1;
  greencube1.translate = Vector.create(10, -8, -2);

  e ~= darkcube1;
  e ~= brightcube1;
  e ~= brightcube2;
  e ~= greencube1;
  e ~= greencube2;
  e ~= rose1;
  return e;
}

