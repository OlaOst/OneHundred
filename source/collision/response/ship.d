module collision.response.ship;

import std.conv;
import std.math;

import gl3n.linalg;

import collision.responsehandler;
import components.collider;
import components.sound;
import entity;
import systems.collisionhandler;
import timer;


//Entity[] shipCollisionResponse(Collision collision, SystemSet systemSet)
Entity[] shipCollisionResponse(Collision collision, CollisionHandler collisionHandler)
{
  auto first = collision.first;
  auto other = collision.other;
    
  //collision.updateFromEntities();
    
  auto firstColliderEntity = collisionHandler.getEntity(first);
  auto otherColliderEntity = collisionHandler.getEntity(other);
  first.isColliding = true;
  other.isColliding = true;
  
  // TODO: collision.check should calculate the contactpoint
  auto contactPoint = ((other.position - first.position) * first.radius + 
                       (first.position - other.position) * other.radius) * 
                      (1.0 / (first.radius + other.radius));

  assert(contactPoint.isFinite, 
         "Bad contactpoint calculation from positions " ~ 
         other.position.to!string ~ " vs " ~ first.position.to!string ~ 
         ", and radii " ~ other.radius.to!string ~ " vs " ~ first.radius.to!string);

  //writeln("contactpoint: ", contactPoint);
  first.contactPoint = first.position + contactPoint;
  other.contactPoint = other.position - contactPoint;
  
  assert(first.contactPoint.isFinite);
  assert(other.contactPoint.isFinite);

  if ("velocity" !in firstColliderEntity.values || "velocity" !in otherColliderEntity.values)
    assert(false);
  
  //auto firstMass = systemSet.physics.getComponent(firstColliderEntity).mass;
  //auto otherMass = systemSet.physics.getComponent(otherColliderEntity).mass;
  auto firstMass = first.mass;
  auto otherMass = other.mass;
  auto firstVelocity = first.velocity * ((firstMass-otherMass) / (firstMass+otherMass)) +
                       other.velocity * ((2 * otherMass) / (firstMass+otherMass));
  auto otherVelocity = other.velocity * ((otherMass-firstMass) / (firstMass+otherMass)) +
                       first.velocity * ((2 * firstMass) / (firstMass+otherMass));
  
  auto momentumBefore = first.velocity * firstMass + other.velocity * otherMass;
  auto momentumAfter = firstVelocity * firstMass + otherVelocity * otherMass;
  assert(approxEqual(momentumBefore.magnitude, momentumAfter.magnitude), 
         "Momentum not conserved in collision: went from " ~ 
         momentumBefore.to!string ~ " to " ~ momentumAfter.to!string);    

  auto firstVel = first.velocity;
  auto otherVel = other.velocity;
  
  // only change velocities if entities are moving towards each other
  if (((other.position+other.velocity*0.01) - (first.position+first.velocity*0.01)).magnitude <
      (other.position-first.position).magnitude)
  {
    firstColliderEntity.values["velocity"] = firstVelocity.to!string;
    otherColliderEntity.values["velocity"] = otherVelocity.to!string;
  }

  // TODO: is it right to integrate by physicsTimeStep here?
  first.force = (firstVelocity * firstMass - first.velocity * firstMass) * 
                (1.0 / Timer.physicsTimeStep) * 1.0;
  other.force = (otherVelocity * otherMass - other.velocity * otherMass) * 
                (1.0 / Timer.physicsTimeStep) * 1.0;
  
  // TODO: change positions to ensure colliders does not overlap
  auto firstPos = firstColliderEntity.values["position"];
  auto otherPos = otherColliderEntity.values["position"];

  Entity[] hitEffectParticles;
  if ((firstVelocity - otherVelocity).magnitude > 1.0)
  {
    auto position = (first.contactPoint + other.contactPoint) * 0.5;
    Entity hitSound = new Entity();
    hitSound.values["position"] = position.to!string;
    hitSound.values["sound"] = "audio/bounce.wav";
    hitEffectParticles ~= hitSound;
  }
  return hitEffectParticles;
}
