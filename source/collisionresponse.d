module collisionresponse;

import std.math;

import artemisd.all;
import gl3n.linalg;

import component.position;
import component.velocity;
import system.collisionhandler;


struct CollisionEntity
{
  Entity entity;
  vec2 position;
  vec2 velocity;
  double radius;
  double mass;
  
  alias entity this;
  
  bool isOverlapping(CollisionEntity other)
  {
    return (position - other.position).magnitude < (radius + other.radius);
  }
}

struct Collision
{
  CollisionEntity first, other;
}

void handleCollisions(Collision[] collisions)
{
  foreach (collision; collisions)
  {
    auto firstVelocity = collision.first.velocity * ((collision.first.mass-collision.other.mass) / 
                                                     (collision.first.mass+collision.other.mass)) +
                         collision.other.velocity * ((2 * collision.other.mass)                  / 
                                                     (collision.first.mass+collision.other.mass));
    auto otherVelocity = collision.other.velocity * ((collision.other.mass-collision.first.mass) / 
                                                     (collision.first.mass+collision.other.mass)) +
                         collision.first.velocity * ((2 * collision.first.mass)                  /
                                                     (collision.first.mass+collision.other.mass));
    
    auto momentumBefore = collision.first.velocity * collision.first.mass + 
                          collision.other.velocity * collision.other.mass;
    auto momentumAfter = firstVelocity * collision.first.mass + 
                         otherVelocity * collision.other.mass;
    assert(approxEqual(momentumBefore.magnitude, momentumAfter.magnitude), 
           "Momentum not conserved in collision: went from " ~ 
           momentumBefore.to!string ~ " to " ~ momentumAfter.to!string);
    
    //debug writeln("changing vel from ", collision.first.velocity, " to ", firstVelocity);
    
    auto firstVel = collision.first.entity.getComponent!Velocity;
    auto otherVel = collision.other.entity.getComponent!Velocity;
    firstVel = firstVelocity;
    otherVel = otherVelocity;
    
    // change positions to ensure colliders does not overlap
    auto firstPos = collision.first.entity.getComponent!Position;
    auto otherPos = collision.other.entity.getComponent!Position;
    
    auto contactPoint = (collision.other.position - collision.first.position);
    
    firstPos += (contactPoint - contactPoint.normalized() * 
                (collision.first.radius+collision.other.radius)) * 0.5;
    otherPos -= (contactPoint - contactPoint.normalized() *
                (collision.first.radius+collision.other.radius)) * 0.5;
  }
}
