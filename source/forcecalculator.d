module forcecalculator;

import std.math;
import std.stdio;

import gl3n.linalg;

import components.collider;
import components.input;
import entity;
import integrator.state;
import playereventhandler;


double calculateTorque(State state, double time) pure nothrow @nogc
out (result)
{
  assert(!result.isNaN);
}
body
{
  //import std.stdio;
  //debug writeln("calculateTorque for ", state.entity.id, " begin");
  
  //auto torque = 0.0;
  double torque = state.torque;
  
  //torque += state.rotation * -0.2; // damping torque
  
  //if (state.entity.input)
    //state.entity.input.handlePlayerRotateActions(torque);
    
  // torque from collisions
  /*if (auto collider = state.entity.collider)
  {
    if (collider.isColliding)
    {
      auto position = state.entity.get!vec3("position");
      auto relative = collider.contactPoint - position;
      
      //writeln("calc cross from collider force ", collider.force, " and rel pos ", relative);
      
      auto cross = collider.force.x * relative.y - collider.force.y * relative.x;
      
      //writeln("calc torque from contactpoint ", collider.contactPoint, " with torque ", cross);
      
      torque -= cross;
    }
  }*/
  
  //debug writeln("calculateTorque for ", state.entity.id, " end");
  
  return torque;
}

vec3 calculateForce(State state, double time) pure nothrow @nogc
out (result)
{
  assert(result.isFinite);
}
body
{
  //import std.stdio;
  //debug writeln("calculateForce for ", state.entity.id, " begin");
  
  auto force = state.force; //vec2(0.0, 0.0);
  
  force += state.position * -0.025; // spring force to center
  force += state.velocity * -0.05; // damping force
/*
  // twisty clockwise force close to center
  auto normalPos = vec3(state.position.y, -state.position.x, 0.0);
  if (normalPos.magnitude() > 0.0)
    force += normalPos.normalized() * ((1.0 / (normalPos.magnitude() + 0.1)) ^^2) * 0.05;

  // twisty counterclockwise force further out
  force += vec3(-state.position.y, state.position.x, 0.0) * 0.015;
*/
  //if (state.entity.input)
    //state.entity.input.handlePlayerAccelerateActions(force, state.angle);

  // force from collisions
  /*if (auto collision = state.entity.collider)
  {
    if (collision.isColliding)
    {
      //force -= collision.force;
    }
  }*/
  
  // clamp force magnitude
  if (force.magnitude > 1_000_000)
    force = force.normalized * 1_000_000;
  
  return force;
}
