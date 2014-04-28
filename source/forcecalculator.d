module forcecalculator;

import std.stdio;

import gl3n.linalg;

import component.collider;
import component.input;
import component.relations.gravity;
import entity;
import integrator.state;
import playereventhandler;


double calculateTorque(State state, double time)
out (result)
{
  assert(!result.isNaN);
}
body
{
  auto torque = 0.0;
  
  torque += state.rotation * -0.2; // damping torque
  
  if (state.entity.input)
    state.entity.input.handlePlayerRotateActions(torque);

  // torque from collisions
  if (auto collider = state.entity.collider)
  {
    if (collider.isColliding)
    {
      auto position = state.entity.vectors["position"];
      auto relative = collider.contactPoint - position;
      
      //writeln("calc cross from collider force ", collider.force, " and rel pos ", relative);
      
      auto cross = collider.force.x * relative.y - collider.force.y * relative.x;
      
      //writeln("calc torque from contactpoint ", collider.contactPoint, " with torque ", cross);
      
      torque -= cross;
    }
  }
  
  return torque;
}

vec2 calculateForce(State state, double time)
out (result)
{
  assert(result.isFinite);
}
body
{
  auto force = vec2(0.0, 0.0);
  
  force += state.position * -0.01; // spring force to center
  force += state.velocity * -0.05; // damping force
  
  // twisty clockwise force close to center
  /*auto normalPos = vec2(state.position.y, -state.position.x);
  if (normalPos.magnitude() > 0.0)
    force += normalPos.normalized() * ((1.0 / (normalPos.magnitude() + 0.1)) ^^2) * 0.05;
    
  // twisty counterclockwise force further out
  force += vec2(-state.position.y, state.position.x) * 0.015;*/
  
  if (state.entity.input)
    state.entity.input.handlePlayerAccelerateActions(force, state.angle);

  // force from collisions
  if (auto collision = state.entity.collider)
  {
    if (collision.isColliding)
    {
      //force -= collision.force;
    }
  }
  
  return force;
}
