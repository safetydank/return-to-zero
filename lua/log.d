module lua.log;

import derelict.lua.lua;
import core.logger;
import std.stdio;
import std.string;

static void InitLuaLogger(lua_State* L)
{
  lua_pushcfunction(L, &LogMessage);
  lua_setglobal(L, toStringz("LogMessage"));
}

extern (C)
{
  static int LogMessage(lua_State* L)
  {
    int n = lua_gettop(L);
    if (n != 1)
      return 0;
    char *message = lua_tolstring(L, 1, null);
    Logger.instance.message(toString(message));

    return 0;
  }
}
