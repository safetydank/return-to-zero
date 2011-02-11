module de.config; 

import std.string;

import derelict.lua.lua;
import de.math;

import core.logger;
import de.script;

class Config
{
  private static Config _instance = null;

  static Config instance()
  {
    if (_instance is null)
      _instance = new Config("config.lua");

    return _instance;
  }

  public int width;
  public int height;
  public bit fullscreen;
  public bit title;
  public bit test;
  public int quadsize;
  public int level;
  public float persistence;

  public Vector colour;

  private lua_State* _L;
   
  private this(char[] configFile)
  {
    Interpreter script = new Interpreter();
    script.run(configFile);
    _L = script.luaState;
    read();
  }

  private void read()
  {
    Logger log = Logger.instance;
    lua_getglobal(_L, "config");
    if (!lua_istable(_L, -1))
    {
      log.message("Error reading config table");
      return;
    }
    
    height = getInt("height");
    width  = getInt("width");
    fullscreen = cast(bit) getInt("fullscreen");
    title = cast(bit) getInt("title");
    test = cast(bit) getInt("test");
    quadsize = getInt("quadsize");
    persistence = getFloat("persistence");
    level = getInt("level");
    log.message(format("Configured width: %d height: %d", width, height));
    log.message(format("Feedback persistence factor: %f", persistence));
  }

  public float getFloat(char[] key)
  {
    lua_pushstring(_L, toStringz(key));
    lua_gettable(_L, -2);
    if (!lua_isnumber(_L, -1))
    {
      Logger.instance.message("getFloat() : not a number");
      return 0;
    }

    float result = cast(float) lua_tonumber(_L, -1);
    lua_pop(_L, 1);
    return result;
  }

  public int getInt(char[] key)
  {
    lua_pushstring(_L, toStringz(key));
    lua_gettable(_L, -2);
    if (!lua_isnumber(_L, -1))
    {
      Logger.instance.message("getInt() : not a number");
      return 0;
    }
    int result = cast(int) lua_tonumber(_L, -1);
    lua_pop(_L, 1);
    return result;
  }

  public char[] getString(char[] key)
  {
    return null;
  }

}
