module de.resourcecache;

class ResourceCache(T)
{
  T[char[]] _resources;

  public void opIndexAssign(T res, char[] key)
  {
    _resources[key] = res;
  }

  public T opIndex(char[] key)
  {
    return _resources[key]; 
  }

  public void unload(char[] key)
  {
  }
}

