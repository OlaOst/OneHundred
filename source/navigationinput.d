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
  
  if (component.isActionSet("accelerate"))
    force += vec3(vec2FromAngle(angle), 0.0) * 0.5;
  if (component.isActionSet("decelerate"))
    force -= vec3(vec2FromAngle(angle), 0.0) * 0.5;
  if (component.isActionSet("rotateCounterClockwise"))
    torque += 1.0;
  if (component.isActionSet("rotateClockwise"))
    torque -= 1.0;

  entity["force"] = force;
  entity["torque"] = torque;
}
