/*  Adapted from Kenta Cho's Actor class  
 *  Copyright 2004 Kenta Cho. Some rights reserved.
 */
module de.actor;

/**
 * An Actor has an interface to move and draw.
 */
abstract class Actor 
{
  public bool exists;

  public void init(Object[] args) {};
  public abstract void move(float elapsed);
}

/**
 * Object pooling for actors.
 */
class ActorPool(T) 
{
  public T[] actors;
  protected int i_actor = 0;

  public this() {}

  public this(int n, Object[] args = null) 
  {
    createActors(n, args);
  }

  protected void createActors(int n, Object[] args = null) 
  {
    actors = new T[n];

    foreach (inout T a; actors) 
    {
      a = new T;
      a.exists = false;
      a.init(args);
    }
    i_actor = 0;
  }

  public T getInstance() 
  {
    for (int i = 0; i < actors.length; i++) 
    {
      i_actor--;
      if (i_actor < 0)
        i_actor = actors.length - 1;
      if (!actors[i_actor].exists) 
        return actors[i_actor];
    }
    return null;
  }

  public T getInstanceForced() 
  {
    i_actor--;
    if (i_actor < 0)
      i_actor = actors.length - 1;
    return actors[i_actor];
  }

  public T[] getMultipleInstances(int n) 
  {
    T[] ret;
    for (int i = 0; i < n; i++) 
    {
      T inst = getInstance();
      if (!inst) 
      {
        foreach (T r; ret)
          r.exists = false;
        return null;
      }
      inst.exists = true;
      ret ~= inst;
    }
    foreach (T r; ret)
      r.exists = false;
    return ret;
  }

  /// Apply foreach over active members
  public int opApply(int delegate(inout T) dg)
  {
    int res;

    foreach (T actor; actors)
    {
      if (actor.exists)
      {
        res = dg(actor);
        if (res)
          break;
      }
    }

    return res;
  }

  public void clear() 
  {
    foreach (T ac; actors)
      ac.exists = false;
    i_actor = 0;
  }
}
