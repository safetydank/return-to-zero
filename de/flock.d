module de.flock;

import de.math;
import de.actor;
import de.physicsbody;

class Flock
{
  ActorPool!(Entity) _pool;
  Entity[] _entities;

  public this()
  {
  }

  void tagNeighbours(Entity entity, Entity[] entities, float radius)
  {
    foreach(check; entities)
    {
      entity.tag = false;

      if (entity is check)
        continue;

      Vector to = check.pos - entity.pos;
      float range = radius + check.boundingRadius;

      if (to.lengthSq < range * range)
        check.tag = true;
    }
  }
}

class Behavior
{
  Entity _entity;

  public Vector separation(Entity[] neighbours)
  {
    Vector steeringForce;

    foreach(neighbour; neighbours)
    {
      // Vector toAgent = 
    }

    // for(int a=0; a<neighbors.size(); ++a)
    // {
    //   //make sure this agent isn't included in the calculations and that
    //   //the agent being examined is close enough.
    //   if((neighbors[a]!=m_pVehicle)&&neighbors[a]->IsTagged())
    //   {
    //     Vector2DToAgent=m_pVehicle->Pos()-neighbors[a]->Pos();
    //     //scaletheforceinverselyproportionaltotheagent'sdistance
    //     //fromitsneighbor.
    //     SteeringForce+=Vec2DNormalize(ToAgent)/ToAgent.Length();
    //   }
    // }

    return steeringForce;
  }
}

class Entity : PhysicsBody
{
  Vector _heading;
  Vector _side;
  float _mass;
  float _maxSpeed;
  float _maxForce;
  float _maxTurnRate;
  float _boundingRadius;

  bool _b_tagged;

  public float boundingRadius() { return _boundingRadius; }
  public this()
  {
    _b_tagged = false;
  }

  public override void init(Object[] args)
  {
  }

  public override void move(float elapsed)
  {
    super.move(elapsed);
  }

  public bool tag(bool t)
  {
    return (_b_tagged = t);
  }

  public void activate()
  {
  }

  protected override Vector acceleration(State state, float t)
  {
    Vector acceleration;

    //  Calculate the combined steering force
    // auto steeringForce = _steering.calc();
    // acceleration = steeringForce / _mass;

    return acceleration;
  }
}


