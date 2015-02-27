module integrator.state;

import std.stdio;

import gl3n.linalg;

import converters;
import entity;


struct State
{
  // primaries
  vec3 position = vec3(0.0, 0.0, 0.0);
  vec3 momentum = vec3(0.0, 0.0, 0.0);
  double angle = 0.0;
  //double rotationalMomentum;
  
  // secondaries
  vec3 velocity = vec3(0.0, 0.0, 0.0);
  double rotation = 0.0;
  
  //constants
  double mass;
  
  // 'constants' for forceCalculator
  vec3 force = vec3(0.0, 0.0, 0.0);
  double torque = 0.0;
  
  vec3 function(State, double time) pure nothrow @nogc forceCalculator;
  double function(State, double time) pure nothrow @nogc torqueCalculator;
  Entity entity;
  
  this() @disable;
  
  this(Entity entity, 
       vec3 function(State, double time) pure nothrow @nogc forceCalculator, 
       double function(State, double time) pure nothrow @nogc torqueCalculator)
  {
    this.entity = entity;

    position = entity.get!vec3("position");
    velocity = entity.get!vec3("velocity");
    angle = entity.get!double("angle");
    rotation = entity.get!double("rotation");
    mass = entity.get!double("mass");
    momentum = velocity * mass;
    
    this.forceCalculator = forceCalculator;
    this.torqueCalculator = torqueCalculator;
  }
  
  void interpolate(State other, double alpha) pure nothrow @nogc
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
    assert(velocity.isFinite, "Infinite speed, force is " ~ force.to!string);
    assert(force.isFinite, "Infinite force");
    assert(!angle.isNaN);
    assert(angle <= PI && angle >= -PI, "Angle out of bounds: " ~ angle.to!string);
    assert(!rotation.isNaN);
    assert(!torque.isNaN);
    //assert(!rotationalMomentum.isNaN);
    assert(mass > 0.0, "Must have positive nonzero mass, was " ~ mass.to!string);
    assert(forceCalculator !is null);
    assert(torqueCalculator !is null);
    assert(entity !is null);
  }
}
