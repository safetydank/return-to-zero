import std.stdio;
import std.string;

import derelict.opengl.gl;

import derelict.sdl.sdl;
import derelict.sdl.image;
import derelict.sdl.mixer;
import derelict.lua.lua;
import derelict.lua.lualib;
import derelict.lua.lauxlib;

import core.logger;

import de.screen;
import de.mainloop;
import de.twinstickpad;
import de.mouse;

import game.gamemanager;

private:
Screen screen;
NullGameManager gameManager;
MainLoop mainLoop;
TwinStickPad pad;
Mouse mouse;

void cleanup()
{
  SDL_Quit();
}

//  Initialize Derelict wrappers
void initLibs()
{
  Logger.instance.message("Initializing derelict libs");
  DerelictSDL.load();
  DerelictSDLMixer.load();
  DerelictSDLImage.load();
  DerelictGL.load();
  DerelictLua.load();
}

void main(char[][] args)
{
  initLibs();

  pad = new TwinStickPad;
  pad.openJoystick();
  mouse = new Mouse;

  screen = new Screen;

  gameManager = new NullGameManager(args);
  mainLoop = new MainLoop(screen, pad, mouse, gameManager);

  mainLoop.loop();

  cleanup();
  return 0;
}

