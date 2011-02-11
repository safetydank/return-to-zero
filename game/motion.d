module game.motion;

import core.util;
import de.math;

enum Cmd_t
{
  JUMP,
  WAIT,
  SET_VELOCITY,
  SET_DIRECTION,
  ROTATE
}

struct Cmd
{
  Cmd_t  command;
  Vector vector;
  float  fparam;
  int    iparam;
  char[] sparam;

  static Cmd create(Cmd_t command, Vector vector)
  {
    Cmd ret;
    ret.command = command;
    ret.vector  = vector;
    return ret;
  }

  static Cmd create(Cmd_t command, float fparam)
  {
    Cmd ret;
    ret.command = command;
    ret.fparam  = fparam;
    return ret;
  }

  static Cmd create(Cmd_t command, int iparam)
  {
    Cmd ret;
    ret.command = command;
    ret.iparam  = iparam;
    return ret;
  }

  static Cmd create(Cmd_t command, char[] sparam)
  {
    Cmd ret;
    ret.command = command;
    ret.sparam  = sparam;
    return ret;
  }
}

class MotionController
{
  bool _loop = false;
  MotionSequence _seq;
  public MotionSequence seq() { return _seq; }

  float _waitTime = 0.0f;
  int _i_command = 0;

  bool _b_active = false;
  public bool active(bool b_active) { return _b_active = b_active; }

  public this(MotionSequence seq)
  {
    _seq = seq;
    _i_command = 0;
  }

  public void move(float elapsed)
  {
    //  If we reached the end of the command list 
    //  in the last iteration
    if (_i_command == -1)
    {
      if (_loop) 
        _i_command = 0;
      else
        _b_active = false;
    }

    if (_b_active)
    {
      Cmd c = _seq[_i_command];
      if (c.command == Cmd_t.WAIT)
        _waitTime += c.fparam;

      if (_waitTime > 0)
        _waitTime = max(0.0f, _waitTime - elapsed);

      //  Move to next command
      _i_command = _seq.next(_i_command);
    }
  }
}

class MotionSequence
{
  Cmd[] _commands;

  int[char[]] _labels;

  bool _b_writing;
  float _elapsed;

  public this()
  {
    _elapsed = 0;
    _b_writing = false;
  }

  public void move(float elapsed)
  in
  {
    assert(_b_writing == false);
  }
  body
  {
  }

  public void begin()
  {
    _b_writing = true;
  }

  public void end()
  {
    _b_writing = false;
  }

  void add(Cmd c)
  in
  {
    assert(_b_writing == true);
  }
  body
  {
    _commands ~= c;
  }

  public void wait(float timeout)
  {
    add(Cmd.create(Cmd_t.WAIT, timeout));
  }

  public void label(char[] l)
  {
    _labels[l] = _commands.length;
  }

  public void jump(char[] label)
  {
    add(Cmd.create(Cmd_t.JUMP, label));
  }

  public Cmd opIndex(int i_command)
  in
  {
    assert(i_command >= 0 && i_command < _commands.length);
  }
  body
  {
    return _commands[i_command];
  }

  public int next(int i_command)
  {
    //  Reached the end
    if (++i_command >= _commands.length)
      return -1;

    //  Check for jumps
    Cmd cur;
    do
    {
      cur = this[i_command];
      if (cur.command == Cmd_t.JUMP)
        i_command = _labels[cur.sparam];
    } while (cur.command == Cmd_t.JUMP)

    return i_command;
  }
}


