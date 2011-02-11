import derelict.lua.lua;

import std.stdio;
import std.string;

import core.logger;

import lua.log;

class Interpreter
{
  lua_State* _pL;

  this()
  {
    _pL = luaL_newstate();
    luaL_openlibs(_pL);

    InitLuaLogger(_pL);
  }

  ~this()
  {
    // XXX lua_close causes a segfault, not sure why
    // lua_close(_pL);
  }

  public lua_State* luaState() { return _pL; }

  void run(char[] script)
  {
    int error = luaL_loadfile(_pL, toStringz(script)) 
      || lua_pcall(_pL, 0, LUA_MULTRET, 0);

    if (error != 0)
      Logger.instance.message(format("Error %d lua script %s", error, script));
  }
}
