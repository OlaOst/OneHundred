module collision.response;

import std.algorithm;
import std.math;
import std.range;
import std.stdio;

import artemisd.all;
import gl3n.linalg;

import collision.check;
import component.collider;
import component.drawable;
import component.position;
import component.sound;
import component.velocity;
import system.collisionhandler;
import timer;


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
    auto first = collision.first;
    auto other = collision.other;
    
    collision.updateFromEntities();
    
    auto firstVelocity = first.velocity * ((first.mass-other.mass) / (first.mass+other.mass)) +
                         other.velocity * ((2 * other.mass) / (first.mass+other.mass));
    auto otherVelocity = other.velocity * ((other.mass-first.mass) / (first.mass+other.mass)) +
                         first.velocity * ((2 * first.mass) / (first.mass+other.mass));
    
    auto momentumBefore = first.velocity * first.mass + other.velocity * other.mass;
    auto momentumAfter = firstVelocity * first.mass + otherVelocity * other.mass;
    assert(approxEqual(momentumBefore.magnitude, momentumAfter.magnitude), 
           "Momentum not conserved in collision: went from " ~ 
           momentumBefore.to!string ~ " to " ~ momentumAfter.to!string);    

    auto firstVel = first.entity.getComponent!Velocity;
    auto otherVel = other.entity.getComponent!Velocity;
    // only change velocities if entities are moving towards each other
    if (((other.position+other.velocity*0.01) - (first.position+first.velocity*0.01)).magnitude <
        (other.position-first.position).magnitude)
    {
      firstVel = firstVelocity;
      otherVel = otherVelocity;
    }

    // TODO: collision.check should calculate the contactpoint
    auto contactPoint = ((other.position - first.position) * first.radius + 
                         (first.position - other.position) * other.radius) * 
                        (1.0 / first.radius + other.radius);
    
    //writeln("contactpoint: ", contactPoint);
    auto firstCollider = first.entity.getComponent!Collider;
    auto otherCollider = other.entity.getComponent!Collider;
    firstCollider.isColliding = true;
    otherCollider.isColliding = true;
    firstCollider.contactPoint = first.position + contactPoint;
    otherCollider.contactPoint = other.position - contactPoint;
    
    // TODO: is it right to integrate by physicsTimeStep here?
    firstCollider.force = (firstVelocity * first.mass - first.velocity * first.mass) * (1.0 / Timer.physicsTimeStep);
    otherCollider.force = (otherVelocity * other.mass - other.velocity * other.mass) * (1.0 / Timer.physicsTimeStep);
    
    // change positions to ensure colliders does not overlap
    auto firstPos = collision.first.entity.getComponent!Position;
    auto otherPos = collision.other.entity.getComponent!Position;
    
    //auto contactPoint = (collision.other.position - collision.first.position);
    
    /*firstPos += (contactPoint - contactPoint.normalized() * 
                (collision.first.radius+collision.other.radius)) * 0.5;
    otherPos -= (contactPoint - contactPoint.normalized() *
                (collision.first.radius+collision.other.radius)) * 0.5;*/
    
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
