module navigationinput;

import std.conv;

import gl3n.linalg;

import components.input;
import converters;
import entity;


void updateValues(Entity entity, Input component)
{
  auto angle = entity.get!double("angle");
  auto force = entity.get!vec3("force");
  auto torque = entity.get!double("torque");
  
  auto engineForce = entity.has("engineForce") ? entity.get!double("engineForce") : 1.0;
  auto engineTorque = entity.has("engineTorque") ? entity.get!double("engineTorque") : 1.0;
  
  if (component.isActionSet("accelerate"))
    force += vec3(vec2FromAngle(angle), 0.0) * engineForce;
  if (component.isActionSet("decelerate"))
    force -= vec3(vec2FromAngle(angle), 0.0) * engineForce;
  if (component.isActionSet("rotateCounterClockwise"))
    torque += engineTorque;
  if (component.isActionSet("rotateClockwise"))
    torque -= engineTorque;

  entity["force"] = force;
  entity["torque"] = torque;
}
