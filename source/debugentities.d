module debugentities;

import std.algorithm;
import std.conv;
import std.math;
import std.range;

import gl3n.linalg;

import components.drawables.polygon;
import entity;
import systemset;


void updateDebugEntities(SystemSet systemSet)
{
  foreach (entityHandler; systemSet.entityHandlers)
  {
    assert(!entityHandler.debugTiming.isNaN);
    
    auto found = systemSet.entities.find!(entity => entity.values.get("name", "") == entityHandler.className);
    
    if (!found.empty)
    {
      auto debugEntity = found.front;
      
      auto prevSize = debugEntity.get!double("size");
      auto size = prevSize * 0.9 + (0.3 + sqrt(entityHandler.debugTiming)*0.1) * 0.1;
      
      auto prevTimePerComponent = debugEntity.get!double("timePerComponent");
      auto timePerComponent = prevTimePerComponent * 0.9 + (entityHandler.debugTiming / entityHandler.componentCount) * 0.1;
      debugEntity.values["timePerComponent"] = timePerComponent.to!string;
      
      assert("name" in debugEntity.values, debugEntity.values.to!string);
      assert("size" in debugEntity.values, debugEntity.values.to!string);
      //import std.stdio;
      //writeln("changing debugentity ", debugEntity.values["name"], " size from ", debugEntity.values["size"], " to ", size);
      
      auto polygon = new Polygon(size, 16, vec4(timePerComponent, 0.67, 0.33, 1.0));
      debugEntity.values["size"] = size.to!string;
      debugEntity.values["polygon.vertices"] = polygon.vertices.to!string;
      debugEntity.values["polygon.colors"] = polygon.colors.to!string;
    }
  }
}
