module collisionresponse;

import std.math;
import std.stdio;

import artemisd.all;
import gl3n.linalg;

import component.position;
import component.sound;
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
  
  void updateFromEntity()
  {
    position = entity.getComponent!Position.position;
    velocity = entity.getComponent!Velocity.velocity;
    // TODO: for now assume that radius and mass does not change
  }
}

struct Collision
{
  CollisionEntity first, other;
  
  void updateFromEntities()
  {
    first.updateFromEntity();
    other.updateFromEntity();
  }
}

void handleCollisions(World world, Collision[] collisions)
{
  foreach (collision; collisions)
  {
    collision.updateFromEntities();
    
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
    // only change velocities if entities are moving towards each other
    if (((collision.other.position + collision.other.velocity*0.01) - 
         (collision.first.position + collision.first.velocity*0.01)).magnitude <
        (collision.other.position - collision.first.position).magnitude)
    {
      firstVel = firstVelocity;
      otherVel = otherVelocity;
    }
    
    // change positions to ensure colliders do not overlap
    /*auto firstPos = collision.first.entity.getComponent!Position;
    auto otherPos = collision.other.entity.getComponent!Position;
    
    auto contactPoint = (collision.other.position - collision.first.position);
    
    firstPos += (contactPoint - contactPoint.normalized() * 
                (collision.first.radius+collision.other.radius)) * 1.0;
    otherPos -= (contactPoint - contactPoint.normalized() *
                (collision.first.radius+collision.other.radius)) * 1.0;*/
                
    
    auto contactPoint = ((collision.other.position - collision.first.position) * collision.first.radius + 
                         (collision.first.position - collision.other.position) * collision.other.radius) * 
                         (1.0 / collision.first.radius + collision.other.radius);
    // add sound entity to world
    //Entity bonk = world.createEntity();
    //bonk.addComponent(new Position(contactPoint));
    //auto sound = new Sound("bounce.wav");
    //sound.startPlaying();
    //bonk.addComponent(sound);
    //bonk.addToWorld();
  }
}
