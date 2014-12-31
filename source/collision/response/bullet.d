module collision.response.bullet;

import std.conv;
import std.math;
import std.random;
import std.range;

import gl3n.linalg;

import collision.responsehandler;
import components.collider;
import components.drawables.polygon;
import components.sound;
import converters;
import entity;
import entityfactory.tests;
import systems.collisionhandler;
import timer;


Entity[] bulletCollisionResponse(Collision collision, CollisionHandler collisionHandler)
{
  auto first = collision.first;
  auto other = collision.other;

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

  first.contactPoint = first.position + contactPoint;
  other.contactPoint = other.position - contactPoint;
  
  assert(first.contactPoint.isFinite);
  assert(other.contactPoint.isFinite);
  
  if (first.type == ColliderType.Bullet)
    firstColliderEntity.toBeRemoved = true;
  if (other.type == ColliderType.Bullet)
    otherColliderEntity.toBeRemoved = true;
    
  Entity[] hitEffectParticles;
  
  // no effects for bullet collisions
  //if (first.type != ColliderType.Bullet || other.type != ColliderType.Bullet)
  {
    int particleCount = uniform(10, 50);
    auto position = (first.contactPoint + other.contactPoint) * 0.5;
    auto momentum = first.velocity*first.mass - other.velocity*other.mass;
    foreach (double index; iota(0, particleCount))
    {
      float size = uniform(0.02, 0.05);
      
      auto particle = new Entity();
      particle.values["position"] = position.to!string;
      auto angle = uniform(-PI, PI);
      
      particle.values["velocity"] = (momentum + vec2FromAngle(angle) * 
                                     uniform(momentum.magnitude * 3.0, 
                                             momentum.magnitude * 6.0 + 0.001)).to!string;
      particle.values["angle"] = angle.to!string;
      particle.values["rotation"] = (angle * 10.0).to!string;
      particle.values["lifeTime"] = uniform(0.5, 1.5).to!string;
      particle.values["mass"] = size.to!string;
      
      auto drawable = new Polygon(size, 3, vec4(uniformDistribution!float(3).vec3, 0.5));
      particle.values["polygon.vertices"] = drawable.vertices.to!string;
      particle.values["polygon.colors"] = drawable.colors.to!string;
      
      hitEffectParticles ~= particle;
    }
    
    Entity hitSound = new Entity();
    hitSound.values["position"] = position.to!string;
    static auto hitSounds = ["audio/mgshot1.wav", "audio/mgshot2.wav", 
                             "audio/mgshot3.wav", "audio/mgshot4.wav"];
    hitSound.values["sound"] = hitSounds.randomSample(1).front.to!string;
    hitEffectParticles ~= hitSound;
    
    Entity hitText = createText(ceil(momentum.magnitude * 10.0).to!string, position);
    hitText.values["size"] = min((momentum.magnitude / 4.0), 6.0).to!string;
    hitText.values["lifeTime"] = 1.0.to!string;
    hitText.values["mass"] = 0.03.to!string;
    hitText.values["velocity"] = vec2(uniform(-0.5, 0.5), 5.0).to!string;
    hitEffectParticles ~= hitText;
  }
  
  return hitEffectParticles;
}
