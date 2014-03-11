module integrator.state;

import std.stdio;

import gl3n.linalg;
import artemisd.all;

import component.mass;
import component.position;
import component.velocity;

struct State
{
  // primaries
  vec2 position;
  vec2 momentum;
  double angle;
  //double rotationalMomentum;
  
  // secondaries
  vec2 velocity;
  double rotation;
  
  //constants
  double mass;
  
  vec2 function(State, double time) forceCalculator;
  double function(State, double time) torqueCalculator;
  Entity entity;
  
  this(Entity entity, 
       vec2 function(State, double time) forceCalculator, 
       double function(State, double time) torqueCalculator)
  {
    this.entity = entity;
  
    auto position = entity.getComponent!Position;
    auto velocity = entity.getComponent!Velocity;
    auto mass = entity.getComponent!Mass;
      
    this.momentum = velocity * mass;
      
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
    momentum = momentum * alpha + other.momentum * (1.0-alpha);
    velocity = velocity * alpha + other.velocity * (1.0-alpha);
    angle = angle * alpha + other.angle * (1.0-alpha);
    rotation = rotation * alpha + other.rotation * (1.0-alpha);
    //rotationalMomentum = rotationalMomentum * alpha + other.rotationalMomentum * (1.0-alpha);
  }
  
  invariant()
  {
    assert(position.isFinite);
    assert(momentum.isFinite);
    assert(velocity.isFinite);
    assert(!angle.isNaN);
    assert(!rotation.isNaN);
    //assert(!rotationalMomentum.isNaN);
    assert(mass > 0.0, "Must have positive nonzero mass");    
    assert(forceCalculator !is null);
    assert(torqueCalculator !is null);
    assert(entity !is null);
  }
}
