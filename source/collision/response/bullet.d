module collision.response.bullet;

import std.conv;
import std.math;
import std.random;
import std.range;

import gl3n.linalg;

import collision.responsehandler;
import components.collider;
import components.drawables.polygon;
import entity;
import timer;


Entity[] bulletCollisionResponse(Collision collision)
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
                      (1.0 / (first.radius + other.radius));

  assert(contactPoint.isFinite, 
         "Bad contactpoint calculation from positions " ~ 
         other.position.to!string ~ " vs " ~ first.position.to!string ~ 
         ", and radii " ~ other.radius.to!string ~ " vs " ~ first.radius.to!string);

  firstCollider.contactPoint = first.position + contactPoint;
  otherCollider.contactPoint = other.position - contactPoint;
  
  assert(firstCollider.contactPoint.isFinite);
  assert(otherCollider.contactPoint.isFinite);
  
  if (first.collider.type == ColliderType.Bullet)
    first.toBeRemoved = true;
  if (other.collider.type == ColliderType.Bullet)
    other.toBeRemoved = true;
    
  Entity[] hitEffectParticles;
  int particleCount = uniform(10, 50);
  auto position = (firstCollider.contactPoint + otherCollider.contactPoint) * 0.5;
  foreach (double index; iota(0, particleCount))
  {
    float size = uniform(0.02, 0.05);
    
    auto particle = new Entity();
    particle.vectors["position"] = position;
    auto momentum = first.velocity*first.mass + other.velocity*other.mass;
    auto angle = uniform(-PI, PI);
    
    particle.vectors["velocity"] = momentum + vec2(cos(angle), sin(angle)) * 
                                   uniform(momentum.magnitude * 3.0, momentum.magnitude * 6.0);
    particle.scalars["angle"] = angle;
    particle.scalars["rotation"] = angle * 10.0;
    particle.scalars["lifeTime"] = uniform(0.5, 1.5);
    particle.scalars["mass"] = size;
    
    auto drawable = new Polygon(size, 3, vec4(uniformDistribution!float(3).vec3, 0.5));
    particle.polygon = drawable;
    
    hitEffectParticles ~= particle;
  }
  
  import components.sound;
  Entity hitSound = new Entity();
  hitSound.vectors["position"] = position;
  static auto hitSounds = ["audio/mgshot1.wav", 
                           "audio/mgshot2.wav", 
                           "audio/mgshot3.wav", 
                           "audio/mgshot4.wav"];
  hitSound.sound = new Sound(hitSounds.randomSample(1).front.to!string);
  hitEffectParticles ~= hitSound;
  
  return hitEffectParticles;
}
