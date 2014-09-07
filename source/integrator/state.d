module integrator.state;

import std.stdio;

import gl3n.linalg;

import converters;
import entity;


struct State
{
  // primaries
  vec2 position = vec2(0.0, 0.0);
  vec2 momentum = vec2(0.0, 0.0);
  double angle = 0.0;
  //double rotationalMomentum;
  
  // secondaries
  vec2 velocity = vec2(0.0, 0.0);
  double rotation = 0.0;
  
  //constants
  double mass;
  
  // 'constants' for forceCalculator
  vec2 force = vec2(0.0, 0.0);
  double torque;
  
  vec2 function(State, double time) forceCalculator;
  double function(State, double time) torqueCalculator;
  Entity entity;
  
  @disable this();
  
  this(Entity entity, 
       vec2 function(State, double time) forceCalculator, 
       double function(State, double time) torqueCalculator)
  {
    this.entity = entity;
  
    auto position = "position" in entity.values ? entity.values["position"].myTo!vec2 : vec2(0.0, 0.0);
    auto velocity = "velocity" in entity.values ? entity.values["velocity"].myTo!vec2 : vec2(0.0, 0.0);
    auto angle = "angle" in entity.values ? entity.values["angle"].to!double : 0.0;
    auto rotation = "rotation" in entity.values ? entity.values["rotation"].to!double : 0.0;
    auto mass = "mass" in entity.values ? entity.values["mass"].to!double : 0.0;
    
    this.momentum = velocity * mass;
      
    assert(position.isFinite);
    assert(velocity.isFinite);
    assert(!angle.isNaN);
    
    assert(!rotation.isNaN);
    assert(!mass.isNaN);
  
    this.position = position;
    this.velocity = velocity;
    this.angle = angle;
    this.rotation = rotation;
    this.mass = mass;
    
    this.forceCalculator = forceCalculator;
    this.torqueCalculator = torqueCalculator;
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
