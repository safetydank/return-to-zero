module de.physicsbody;

import de.actor;
import de.math;

//  Base entity subject to a physical force
//  F = ma
public class ForceBody : PhysicsBody
{
  public Vector force;

  protected override Vector acceleration(State state, float t) 
  { 
    return force / mass;
  }
}

public class PhysicsBody : Actor
{
  public:
    struct State
    {
      Vector pos;
      Vector vel;
    }

    struct Derivative
    {
      Vector dp;
      Vector dv;
    }

    State _state;
    float _t = 0;
    const float DT = 1 / 60.0f;

    public float  mass = 1.0;
    public Vector pos()   { return _state.pos; }
    public Vector pos(Vector p)   { return _state.pos = p; }

    public Vector vel()   { return _state.vel; }
    public Vector vel(Vector v)   { return _state.vel = v; }

    //  Useful for initializing state from an external source
    public void init(float t, Vector pos, Vector vel)
    {
      _t = t;
      _state.pos = pos;
      _state.vel = vel;
    }

    public void moveWith(T)(T obj, float elapsed)
    {
       move(elapsed); 
       obj.pos = _state.pos;
       obj.vel = _state.vel;
    }

    invariant 
    {
      assert(_state.pos.x <>= 0);
      assert(_state.pos.y <>= 0);
      assert(_state.pos.z <>= 0);
      assert(_state.vel.x <>= 0);
      assert(_state.vel.y <>= 0);
      assert(_state.vel.z <>= 0);
    }

    protected Derivative evaluate(State initial, float t)
    {
      Derivative output;
      output.dp = initial.vel;
      output.dv = acceleration(initial, t);
      return output;
    }

    protected Derivative evaluate(State initial, float t, float dt, Derivative d)
    {
      State state;
      state.pos = initial.pos + d.dp * dt;
      state.vel = initial.vel + d.dv * dt;

      Derivative output;
      output.dp = state.vel;
      output.dv = acceleration(state, t+dt);
      return output;
    }

    public void reset()
    {
      _t = 0;
    }

    public override void move(float elapsed)
    {
      integrate(_state, _t, DT);
      _t += DT;
    }

    //  Override this to define motion of the body
    protected Vector acceleration(State state, float t) { return Vector.zero; }

    protected void integrate(inout State state, float t, float dt)
    {
      Derivative a = evaluate(state, t);
      Derivative b = evaluate(state, t, dt*0.5f, a);
      Derivative c = evaluate(state, t, dt*0.5f, b);
      Derivative d = evaluate(state, t, dt, c);

      Vector dpdt = 1.0f/6.0f * (a.dp + 2.0f*(b.dp + c.dp) + d.dp);
      Vector dvdt = 1.0f/6.0f * (a.dv + 2.0f*(b.dv + c.dv) + d.dv);

      state.pos = state.pos + dpdt*dt;
      state.vel = state.vel + dvdt*dt;
    }
}

