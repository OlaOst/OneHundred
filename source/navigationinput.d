module navigationinput;

import std.conv;

import gl3n.linalg;

import components.input;
import converters;
import entity;


void updateValues(Entity entity, Input component)
{
  auto angle = entity.get!double("angle");
  auto force = entity.get!vec2("force");
  auto torque = entity.get!double("torque");
  
  if (component.isActionSet("accelerate"))
    force += vec2FromAngle(angle) * 0.5;
  if (component.isActionSet("decelerate"))
    force -= vec2FromAngle(angle) * 0.5;
  if (component.isActionSet("rotateCounterClockwise"))
    torque += 1.0;
  if (component.isActionSet("rotateClockwise"))
    torque -= 1.0;

  entity.values["force"] = force.to!string;
  entity.values["torque"] = torque.to!string;
}
