module forcecalculator;

import std.stdio;

import gl3n.linalg;

import component.collider;
import component.input;
import component.relations.gravity;
import entity;
import integrator.state;


double calculateTorque(State state, double time)
out (result)
{
  assert(!result.isNaN);
}
body
{
  auto torque = 0.0;
  
  torque += state.rotation * -0.02; // damping torque
  
  auto input = state.entity.input;
  
  if (!input)
  {
    //torque += (1.0 / state.position.magnitude) * 0.5;
  }
  
  if (input && (input.getActionState("rotateLeft") == Input.ActionState.Pressed || input.getActionState("rotateLeft") == Input.ActionState.Held))
    torque += 1.0;
  if (input && (input.getActionState("rotateRight") == Input.ActionState.Pressed || input.getActionState("rotateRight") == Input.ActionState.Held))
    torque -= 1.0;

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
  
  auto input = state.entity.input;
  
  if (input && (input.getActionState("accelerate") == Input.ActionState.Pressed || input.getActionState("accelerate") == Input.ActionState.Held))
    force += vec2(sin(-state.angle), cos(-state.angle)) * 0.5;
  if (input && (input.getActionState("decelerate") == Input.ActionState.Pressed || input.getActionState("decelerate") == Input.ActionState.Held))
    force -= vec2(sin(-state.angle), cos(-state.angle)) * 0.5;
  
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
