module integrator.state;

import std.stdio;

import gl3n.linalg;
import artemisd.all;

import component.mass;
import component.position;
import component.velocity;

struct State
{
  vec2 position;
  vec2 velocity;
  double angle;
  double rotation;
  double mass;  
  vec2 delegate(State, double time) forceCalculator;
  double delegate(State, double time) torqueCalculator;
  Entity entity;
  
  this(Entity entity, 
       vec2 delegate(State, double time) forceCalculator, 
       double delegate(State, double time) torqueCalculator)
  {
    this.entity = entity;
  
    auto position = entity.getComponent!Position;
    auto velocity = entity.getComponent!Velocity;
    auto mass = entity.getComponent!Mass;
      
    assert(position !is null);
    assert(velocity !is null);
    assert(mass !is null);
  
    this.position = position;
    this.velocity = velocity;
    this.angle = position.angle;
    this.rotation = velocity.rotation;
    this.mass = mass;
    
    this.forceCalculator = forceCalculator;
    this.torqueCalculator = torqueCalculator;
  }
  
  void updateComponents()
  {
    auto position = entity.getComponent!Position;
    auto velocity = entity.getComponent!Velocity;
    auto mass = entity.getComponent!Mass;
      
    assert(position !is null);
    assert(velocity !is null);
    assert(mass !is null);
    
    position.position = this.position;
    velocity.velocity = this.velocity;
    position.angle = this.angle;
    velocity.rotation = this.rotation;
  }
  
  void interpolate(State other, double alpha)
  {
    position = position * alpha + other.position * (1.0-alpha);
    velocity = velocity * alpha + other.velocity * (1.0-alpha);
    angle = angle * alpha + other.angle * (1.0-alpha);
    rotation = rotation * alpha + other.rotation * (1.0-alpha);
  }
  
  invariant()
  {
    assert(position.ok);
    assert(velocity.ok);
    assert(!angle.isNaN);
    assert(!rotation.isNaN);
    assert(mass > 0.0, "Must have positive nonzero mass");    
    assert(forceCalculator !is null);
    assert(torqueCalculator !is null);
    assert(entity !is null);
  }
}

struct Derivative
{
  vec2 position = vec2(0.0, 0.0);
  vec2 velocity = vec2(0.0, 0.0);
  double angle = 0.0;
  double rotation = 0.0;
  
  invariant()
  {
    assert(position.ok);
    assert(velocity.ok);
    assert(!angle.isNaN);
    assert(!rotation.isNaN);
  }
}
