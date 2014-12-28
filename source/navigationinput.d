module navigationinput;

import std.conv;

import gl3n.linalg;

import components.input;
import converters;
import entity;


void updateValues(Entity entity, Input component)
{
  auto angle = "angle" in entity.values ? entity.values["angle"].to!double : 0.0;
  auto force = "force" in entity.values ? entity.values["force"].myTo!vec2 : vec2(0.0, 0.0);
  auto torque = "torque" in entity.values ? entity.values["torque"].to!double : 0.0;
  
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
