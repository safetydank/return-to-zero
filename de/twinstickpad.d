/*
 * Copyright 2006 Kenta Cho. Some rights reserved.
 */

module expand.twinstickpad;

private import std.string;
private import std.stream;
private import std.math;
private import derelict.sdl.sdl;
private import de.math;
private import de.input;

/**
 * Twinstick and buttons input.
 */
class TwinStickPad: Input 
{
 public:
  static float rotate = 0;
  static float reverse = 1;
  static bool buttonReversed = false;
  static bool enableAxis5 = false;
  static bool disableStick2 = false;
  Uint8 *keys;
 private:
  SDL_Joystick *stick = null;
  const int JOYSTICK_AXIS_MAX = 32768;
  TwinStickPadState state;

  public this() {
    state = new TwinStickPadState;
  }

  public SDL_Joystick* openJoystick(SDL_Joystick *st = null) {
    if (st is null) {
      if (SDL_InitSubSystem(SDL_INIT_JOYSTICK) < 0)
        return null;
      stick = SDL_JoystickOpen(0);
    } else {
      stick = st;
    }
    return stick;
  }

  public void handleEvent(SDL_Event *event) {
    keys = SDL_GetKeyState(null);
  }

  public TwinStickPadState getState() {
    if (stick) {
      state.left.x = adjustAxis(SDL_JoystickGetAxis(stick, 0));
      state.left.y = -adjustAxis(SDL_JoystickGetAxis(stick, 1));
      int rx = 0, ry = 0;
      if (!disableStick2) {
        if (enableAxis5)
          rx = SDL_JoystickGetAxis(stick, 4);
        else
          rx = SDL_JoystickGetAxis(stick, 2);
        ry = SDL_JoystickGetAxis(stick, 3);
      }
      if (rx == 0 && ry == 0) {
        state.right.x = state.right.y = 0;
      } else {
        ry = -ry;
        float rd = atan2(rx, ry) * reverse + rotate;
        assert(rd <>= 0);
        float rl = sqrt(cast(float) rx * rx + cast(float) ry * ry);
        assert(rl <>= 0);
        state.right.x = adjustAxis(cast(int) (sin(rd) * rl));
        state.right.y = adjustAxis(cast(int) (cos(rd) * rl));
      }
    } else {
      state.left.x = state.left.y = state.right.x = state.right.y = 0;
    }
    if (keys[SDLK_RIGHT] == SDL_PRESSED || keys[SDLK_KP6] == SDL_PRESSED ||
        keys[SDLK_d] == SDL_PRESSED)
      state.left.x = 1;
    if (keys[SDLK_l] == SDL_PRESSED)
      state.right.x = 1;
    if (keys[SDLK_LEFT] == SDL_PRESSED || keys[SDLK_KP4] == SDL_PRESSED ||
        keys[SDLK_a] == SDL_PRESSED)
      state.left.x = -1;
    if (keys[SDLK_j] == SDL_PRESSED)
      state.right.x = -1;
    if (keys[SDLK_DOWN] == SDL_PRESSED || keys[SDLK_KP2] == SDL_PRESSED ||
        keys[SDLK_s] == SDL_PRESSED)
      state.left.y = -1;
    if (keys[SDLK_k] == SDL_PRESSED)
      state.right.y = -1;
    if (keys[SDLK_UP] == SDL_PRESSED ||  keys[SDLK_KP8] == SDL_PRESSED ||
        keys[SDLK_w] == SDL_PRESSED)
      state.left.y = 1;
    if (keys[SDLK_i] == SDL_PRESSED)
      state.right.y = 1;
    state.button = 0;
    int btn1 = 0, btn2 = 0;
    if (stick) {
      btn1 = SDL_JoystickGetButton(stick, 0) + SDL_JoystickGetButton(stick, 2) +
             SDL_JoystickGetButton(stick, 4) + SDL_JoystickGetButton(stick, 6) +
             SDL_JoystickGetButton(stick, 8) + SDL_JoystickGetButton(stick, 10);
      btn2 = SDL_JoystickGetButton(stick, 1) + SDL_JoystickGetButton(stick, 3) +
             SDL_JoystickGetButton(stick, 5) + SDL_JoystickGetButton(stick, 7) +
             SDL_JoystickGetButton(stick, 9) + SDL_JoystickGetButton(stick, 11);
      if (enableAxis5) {
        int ax2 = SDL_JoystickGetAxis(stick, 2);
        if (ax2 > JOYSTICK_AXIS_MAX / 3 || ax2 < -JOYSTICK_AXIS_MAX / 3)
          btn2 = 1;
      }
    }
    if (keys[SDLK_z] == SDL_PRESSED || keys[SDLK_PERIOD] == SDL_PRESSED ||
        keys[SDLK_LCTRL] == SDL_PRESSED || keys[SDLK_RCTRL] == SDL_PRESSED || 
        btn1) {
      if (!buttonReversed)
        state.button |= TwinStickPadState.Button.A;
      else
        state.button |= TwinStickPadState.Button.B;
    }
    if (keys[SDLK_x] == SDL_PRESSED || keys[SDLK_SLASH] == SDL_PRESSED ||
        keys[SDLK_LALT] == SDL_PRESSED || keys[SDLK_RALT] == SDL_PRESSED ||
        keys[SDLK_LSHIFT] == SDL_PRESSED || keys[SDLK_RSHIFT] == SDL_PRESSED ||
        keys[SDLK_RETURN] == SDL_PRESSED || keys[SDLK_SPACE] == SDL_PRESSED ||
        btn2) {
      if (!buttonReversed)
        state.button |= TwinStickPadState.Button.B;
      else
        state.button |= TwinStickPadState.Button.A;
    }
    return state;
  }

  private float adjustAxis(int v) {
    float a = 0;
    if (v > JOYSTICK_AXIS_MAX / 3) {
      a = cast(float) (v - JOYSTICK_AXIS_MAX / 3) /
        (JOYSTICK_AXIS_MAX - JOYSTICK_AXIS_MAX / 3);
      if (a > 1)
        a = 1;
    } else if (v < -(JOYSTICK_AXIS_MAX / 3)) {
      a = cast(float) (v + JOYSTICK_AXIS_MAX / 3) /
        (JOYSTICK_AXIS_MAX - JOYSTICK_AXIS_MAX / 3);
      if (a < -1)
        a = -1;
    }
    return a;
  }

  public TwinStickPadState getNullState() {
    state.clear();
    return state;
  }
}

class TwinStickPadState 
{
 public:
  static enum Button {
    A = 16, B = 32, ANY = 48,
  };
  Vector left, right;
  int button;
 private:

  invariant {
    assert(left.x >= -1 && left.x <= 1);
    assert(left.y >= -1 && left.y <= 1);
    assert(right.x >= -1 && right.x <= 1);
    assert(right.y >= -1 && right.y <= 1);
  }

  public static TwinStickPadState newInstance() {
    return new TwinStickPadState;
  }

  public static TwinStickPadState newInstance(TwinStickPadState s) {
    return new TwinStickPadState(s);
  }

  public this() 
  {
  }

  public this(TwinStickPadState s) {
    this();
    set(s);
  }

  public void set(TwinStickPadState s) {
    left.x = s.left.x;
    left.y = s.left.y;
    right.x = s.right.x;
    right.y = s.right.y;
    button = s.button;
  }

  public void clear() {
    left.x = left.y = right.x = right.y = 0;
    button = 0;
  }

  // public void read(File fd) {
  //   fd.read(left.x);
  //   fd.read(left.y);
  //   fd.read(right.x);
  //   fd.read(right.y);
  //   fd.read(button);
  // }

  // public void write(File fd) {
  //   fd.write(left.x);
  //   fd.write(left.y);
  //   fd.write(right.x);
  //   fd.write(right.y);
  //   fd.write(button);
  // }

  public bool equals(TwinStickPadState s) {
    return (left.x == s.left.x && left.y == s.left.y &&
            right.x == s.right.x && right.y == s.right.y &&
            button == s.button);
  }

  public char[] toString() {
    return format("lx: %f ly: %f", left.x, left.y);
  }
}


