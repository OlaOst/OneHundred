module collision.response;

import std.algorithm;
import std.math;
import std.range;
import std.stdio;

import artemisd.all;
import gl3n.linalg;

import collision.check;
import component.drawable;
import component.position;
import component.sound;
import component.velocity;
import system.collisionhandler;


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

    auto contactPoint = ((collision.other.position - collision.first.position) 
                         * collision.first.radius + 
                         (collision.first.position - collision.other.position) 
                         * collision.other.radius) * 
                         (1.0 / collision.first.radius + collision.other.radius);
    
    // add sound entity to world
    // TODO: stop this from leaking, sound entities should be destroyed or recycled
    // when they stop playing
    Entity bonk = world.createEntity();
    bonk.addComponent(new Position(contactPoint, 0.0));
    auto sound = new Sound("bounce.wav");
    bonk.addComponent(sound);
    //bonk.addToWorld();
  }
}
