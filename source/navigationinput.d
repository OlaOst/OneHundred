module navigationinput;

import std.algorithm;
import std.conv;
import std.random;
import std.range;

import gl3n.linalg;

import components.drawables.polygon;
import components.input;
import converters;
import entity;


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
    
    spawnEntities ~= createExhausts(entity, 10);
  }
  if (component.isActionSet("decelerate"))
  {
    force -= vec3(vec2FromAngle(angle), 0.0) * engineForce;
    
    spawnEntities ~= createExhausts(entity, 5);
  }
  if (component.isActionSet("rotateCounterClockwise"))
    torque += engineTorque;
  if (component.isActionSet("rotateClockwise"))
    torque -= engineTorque;

  entity["force"] = force;
  entity["torque"] = torque;
  
  return spawnEntities;
}

Entity[] createExhausts(Entity engine, uint count)
{
  Entity[] exhausts;
  
  for (uint index = 0; index < count; index++)
    exhausts ~= createExhaust(engine);
  
  return exhausts;
}

Entity createExhaust(Entity engine)
{
  auto exhaust = new Entity();
  exhaust["position"] = engine.get!vec3("position");
  exhaust["velocity"] = engine.get!vec3("velocity") * 0.0 - vec3(vec2FromAngle(engine.get!double("angle") + uniform(-0.1, 0.1)), 0.0) * uniform(5.0, 10.0);
  exhaust["angle"] = engine.get!double("angle");
  exhaust["mass"] = uniform(0.05, 0.25);
  exhaust["rotation"] = uniform(-10.0, 10.0);
  exhaust["lifeTime"] = uniform(1.0, 2.0);
  auto size = uniform(0.25, 0.33);
  
  auto polygon = new Polygon(size, 5, vec4(uniformDistribution!float(3).vec3, 0.05));
  exhaust.polygon = polygon;
  
  return exhaust;
}
