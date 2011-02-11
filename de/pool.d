module de.pool;

/**
 * Basic object pooling, extracted from MemberPool
 */
class Pool(T) 
{
  public T[] members;
  protected int i_member = 0;

  public this() {}

  public this(int n)
  {
    createMembers(n);
  }

  protected void createMembers(int n)
  {
    members = new T[n];

    foreach (inout T a; members) 
    {
      a = new T;
      a.exists = false;
    }
    i_member = 0;
  }

  public T getInstance() 
  {
    for (int i = 0; i < members.length; i++) 
    {
      i_member--;
      if (i_member < 0)
        i_member = members.length - 1;
      if (!members[i_member].exists) 
        return members[i_member];
    }
    return null;
  }

  public T getInstanceForced() 
  {
    i_member--;
    if (i_member < 0)
      i_member = members.length - 1;
    return members[i_member];
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

    foreach (T member; members)
    {
      if (member.exists)
      {
        res = dg(member);
        if (res)
          break;
      }
    }

    return res;
  }

  public void clear() 
  {
    foreach (T ac; members)
      ac.exists = false;
    i_member = 0;
  }
}

