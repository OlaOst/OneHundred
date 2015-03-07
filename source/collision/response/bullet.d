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
import entityfactory.texts;
import systems.collisionhandler;


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
    firstColliderEntity["ToBeRemoved"] = true;
  if (other.type == ColliderType.Bullet)
    otherColliderEntity["ToBeRemoved"] = true;
    
  Entity[] hitEffectParticles;
  
  // no effects for bullet collisions
  //if (first.type != ColliderType.Bullet || other.type != ColliderType.Bullet)
  {
    int particleCount = uniform(10, 50);
    auto position = (first.contactPoint + other.contactPoint) * 0.5;
    auto momentum = first.velocity*first.mass - other.velocity*other.mass;
    foreach (double index; iota(0, particleCount))
    {
      double size = uniform(0.02, 0.05);
      
      auto particle = new Entity();
      particle["position"] = position;
      auto angle = uniform(-PI, PI);
      
      particle["velocity"] = momentum + vec3(vec2FromAngle(angle), 0.0) * uniform(momentum.magnitude * 3.0, momentum.magnitude * 6.0 + 0.001);
      particle["angle"] = angle;
      particle["rotation"] = (angle * 10.0);
      particle["lifeTime"] = uniform(0.5, 1.5);
      particle["mass"] = size;
      
      auto polygon = new Polygon(size, 3, vec4(uniformDistribution!float(3).vec3, 0.5));
      particle.polygon = polygon;
      assert(particle.get!double("mass") > 0.0);
      hitEffectParticles ~= particle;
    }
    
    Entity hitSound = new Entity();
    hitSound["position"] = position;
    static auto hitSounds = ["audio/mgshot1.wav", "audio/mgshot2.wav", 
                             "audio/mgshot3.wav", "audio/mgshot4.wav"];
    hitSound["sound"] = hitSounds.randomSample(1).front;
    hitEffectParticles ~= hitSound;
    
    Entity hitText = createText(ceil(momentum.magnitude * 10.0).to!string, position);
    hitText["size"] = min((momentum.magnitude / 4.0), 6.0);
    hitText["lifeTime"] = 1.0;
    hitText["mass"] = 0.03;
    hitText["velocity"] = vec3(uniform(-0.5, 0.5), 5.0, 0.0);
    assert(hitText.get!double("mass") > 0.0);
    hitEffectParticles ~= hitText;
  }  
  return hitEffectParticles;
}
