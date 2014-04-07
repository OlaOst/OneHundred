module collision.response;

import std.algorithm;
import std.math;
import std.range;
import std.stdio;

import gl3n.linalg;

import collision.check;
import component.collider;
import component.sound;
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

void handleCollisions(Collision[] collisions)
{
  foreach (collision; collisions)
  {
    auto first = collision.first;
    auto other = collision.other;
    
    collision.updateFromEntities();
    
    auto firstCollider = first.entity.collider;
    auto otherCollider = other.entity.collider;
    firstCollider.isColliding = true;
    otherCollider.isColliding = true;
    
    // TODO: collision.check should calculate the contactpoint
    auto contactPoint = ((other.position - first.position) * first.radius + 
                         (first.position - other.position) * other.radius) * 
                        (1.0 / first.radius + other.radius);

    assert(contactPoint.isFinite);

    //writeln("contactpoint: ", contactPoint);
    firstCollider.contactPoint = first.position + contactPoint;
    otherCollider.contactPoint = other.position - contactPoint;
    
    assert(firstCollider.contactPoint.isFinite);
    assert(otherCollider.contactPoint.isFinite);
        
    if ("velocity" !in first.vectors || "velocity" !in other.vectors)
      return;
    
    auto firstVelocity = first.velocity * ((first.mass-other.mass) / (first.mass+other.mass)) +
                         other.velocity * ((2 * other.mass) / (first.mass+other.mass));
    auto otherVelocity = other.velocity * ((other.mass-first.mass) / (first.mass+other.mass)) +
                         first.velocity * ((2 * first.mass) / (first.mass+other.mass));
    
    auto momentumBefore = first.velocity * first.mass + other.velocity * other.mass;
    auto momentumAfter = firstVelocity * first.mass + otherVelocity * other.mass;
    assert(approxEqual(momentumBefore.magnitude, momentumAfter.magnitude), 
           "Momentum not conserved in collision: went from " ~ 
           momentumBefore.to!string ~ " to " ~ momentumAfter.to!string);    

    auto firstVel = first.entity.vectors["velocity"];
    auto otherVel = other.entity.vectors["velocity"];
    // only change velocities if entities are moving towards each other
    if (((other.position+other.velocity*0.01) - (first.position+first.velocity*0.01)).magnitude <
        (other.position-first.position).magnitude)
    {
      firstVel = firstVelocity;
      otherVel = otherVelocity;
    }

    // TODO: is it right to integrate by physicsTimeStep here?
    firstCollider.force = (firstVelocity * first.mass - first.velocity * first.mass) * 
                          (1.0 / Timer.physicsTimeStep);
    otherCollider.force = (otherVelocity * other.mass - other.velocity * other.mass) * 
                          (1.0 / Timer.physicsTimeStep);
    
    // change positions to ensure colliders does not overlap
    auto firstPos = collision.first.entity.vectors["position"];
    auto otherPos = collision.other.entity.vectors["position"];
    
    // add sound entity to world
    // TODO: stop this from leaking, sound entities should be destroyed or recycled
    // when they stop playing
    //Entity bonk = world.createEntity();
    //bonk.addComponent(new Position(contactPoint, 0.0));
    //bonk.addComponent(new Sound("audio/bounce.wav"));
    //bonk.addToWorld();
  }
}
