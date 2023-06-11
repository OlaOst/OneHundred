module navigationinput;

import std.algorithm;
import std.conv;
import std.math;
import std.random;
import std.range;

import inmath.linalg;

import components.input;
import converters;
import entity;
import renderer.polygon;


Entity[] updateValuesAndGetSpawns(Entity entity, Input component)
{
  auto angle = entity.get!double("angle");
  auto force = entity.get!vec3("force");
  auto torque = entity.get!double("torque");
  
  auto engineForce = entity.has("engineForce") ? entity.get!double("engineForce") : 1.0;
  auto engineTorque = entity.has("engineTorque") ? entity.get!double("engineTorque") : 1.0;
  
  Entity[] spawnEntities;
  
  if (component.isActionSet("accelerate"))
  {
    force += vec3(vec2FromAngle(angle), 0.0) * engineForce;
    
    spawnEntities ~= createExhausts(entity, false, 10);
  }
  if (component.isActionSet("decelerate"))
  {
    force -= vec3(vec2FromAngle(angle), 0.0) * engineForce;
    
    spawnEntities ~= createExhausts(entity, true, 5);
  }
  
  if (entity.get!double("rotation") < 20.0)
  {
    if (component.isActionSet("rotateCounterClockwise"))
      torque += engineTorque;
    if (component.isActionSet("rotateClockwise"))
      torque -= engineTorque;
  }

  // dampen rotation when there is no rotation input
  if (!component.isActionSet("rotateCounterClockwise") &&
      !component.isActionSet("rotateClockwise"))
    torque -= entity.get!double("rotation") * engineTorque;

  entity["force"] = force;
  entity["torque"] = torque;
  
  return spawnEntities;
}

Entity[] createExhausts(Entity engine, bool reverse, uint count)
{
  Entity[] exhausts;
  
  for (uint index = 0; index < count; index++)
    exhausts ~= createExhaust(engine, reverse);
  
  return exhausts;
}

Entity createExhaust(Entity engine, bool reverse)
{
  auto exhaust = new Entity();
  exhaust["position"] = engine.get!vec3("position");
  
  if (reverse)
    exhaust["velocity"] = vec3(vec2FromAngle(engine.get!double("angle")
                               + ([-1,1].randomSample(1).front * PI/3) + uniform(-0.1, 0.1)), 0.0)
                          * uniform(3.0, 7.0);
  else
    exhaust["velocity"] = -vec3(vec2FromAngle(engine.get!double("angle")
                                + uniform(-0.1, 0.1)), 0.0)
                          * uniform(5.0, 10.0) + engine.get!vec3("velocity");
  exhaust["angle"] = engine.get!double("angle");
  exhaust["mass"] = uniform(0.05, 0.25);
  exhaust["rotation"] = uniform(-10.0, 10.0);
  exhaust["lifeTime"] = uniform(1.0, 2.0);
  auto size = uniform(0.25, 0.33);
  
  exhaust["graphicsource"] = "polygon";
  auto polygon = new Polygon(size, 5, vec4(uniformDistribution!float(3).vec3, 0.05));
  exhaust["polygon.vertices"] = polygon.vertices;
  exhaust["polygon.colors"] = polygon.colors;
  exhaust["size"] = size;
  //exhaust.polygon = polygon;
  
  return exhaust;
}
