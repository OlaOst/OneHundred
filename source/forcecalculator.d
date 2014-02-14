module forcecalculator;

import gl3n.linalg;

import component.collider;
import component.input;
import component.position;
import component.relations.gravity;
import integrator.state;


double calculateTorque(State state, double time)
{
  auto torque = 0.0;
  
  torque += state.rotation * -0.2; // damping torque
  
  auto input = state.entity.getComponent!Input;
  
  if (!input)
  {
    //torque += (1.0 / state.position.magnitude) * 0.5;
  }
  
  if (input && "rotateLeft" in input.isActive && input.isActive["rotateLeft"])
    torque += 1.0;
  if (input && "rotateRight" in input.isActive && input.isActive["rotateRight"])
    torque -= 1.0;
    
  // torque from collisions
  if (auto collision = state.entity.getComponent!Collider)
  {
    if (collision.isColliding)
    {
      auto position = state.entity.getComponent!Position;
      auto relative = collision.contactPoint - position;
      
      auto cross = collision.force.x * relative.y - collision.force.y * relative.x;
      
      //import std.stdio;
      //writeln("calc torque from contactpoint ", collision.contactPoint, " with torque ", cross);
      
      torque += cross;
    }
  }
  
  return torque;
}

vec2 calculateForce(State state, double time)
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
  
  auto input = state.entity.getComponent!Input;
  
  if (input && "accelerate" in input.isActive && input.isActive["accelerate"])
    force += vec2(cos(state.angle), sin(state.angle)) * 0.5;
  if (input && "decelerate" in input.isActive && input.isActive["decelerate"])
    force -= vec2(cos(state.angle), sin(state.angle)) * 0.5;
  
  if (auto gravity = state.entity.getComponent!Gravity)
  {
    vec2 gravityForce = gravity.getAccumulatedGravityForce(state.position, state.mass);
    gravityForce *= 0.5;
    force += gravityForce;
  }
  
  // torque from collisions
  if (auto collision = state.entity.getComponent!Collider)
  {
    if (collision.isColliding)
    {
      //force += collision.force;
    }
  }
  
  return force;
}
