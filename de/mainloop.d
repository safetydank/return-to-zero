module de.mainloop;

import std.stdio;

import derelict.sdl.sdl;
import de.screen;
import de.input;

import de.gamemanager;
import de.twinstickpad;
import de.mouse;
import core.logger;

class MainLoop
{
  public SDL_Event event;

  private Screen _screen;
  private GameManager _gameManager;
  private MultipleInputDevice _input;

  private bool _running;
  private bool _paused;
  float interval = 16;
  bool accframe = false;

  int maxSkipFrame = 5;

  this(Screen screen, TwinStickPad pad, Mouse mouse, GameManager gameManager)
  {
    _screen = screen;
    _input = new MultipleInputDevice;
    _input.inputs ~= pad;
    _input.inputs ~= mouse;

    _gameManager = gameManager;
    _gameManager.mainLoop = this;
    _gameManager.screen = screen;
    _gameManager.input = _input;
    _gameManager.pad = pad;
    _gameManager.mouse = mouse;
  }

  void init()
  {
    _screen.init();
    _gameManager.init();
  }

  void breakLoop()
  {
    _running = false;
  }

  void pause()
  {
    _paused = !(_paused);
  }

  void loop()
  {
    // main loop flag
    _running = true;
    _paused = false;

    long prevTickCount = 0;
    long nowTick;
    int  frame;

    init();

    // main loop
    while (_running)
    {
      if (SDL_PollEvent(&event) == 0)
        event.type = SDL_USEREVENT;

      _input.handleEvent(&event);

      if (_paused)
      {
        SDL_Delay(10);
        continue;
      }

      if (event.type == SDL_QUIT)
        breakLoop();

      nowTick = SDL_GetTicks();
      float elapsed = (nowTick - prevTickCount) / 1000.0;
      prevTickCount = nowTick;

      int itv = cast(int) interval;
      frame = cast(int) (nowTick - prevTickCount) / itv;
      if (frame <= 0)
      {
        frame = 1;
        SDL_Delay(prevTickCount + itv - nowTick);
        if (accframe) prevTickCount = SDL_GetTicks();
        else prevTickCount += interval;
      }
      else if (frame > maxSkipFrame)
      {
        frame = maxSkipFrame;
        prevTickCount = nowTick;
      }
      else
      {
        prevTickCount = nowTick;
      }

      // Logger.instance.message(format("elapsed %f", elapsed));
      for (int i=0; i < frame; ++i)
        _gameManager.move(interval / 1000.0);

      _gameManager.draw();
    }
  }


}
