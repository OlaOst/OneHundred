module debugentities;

import std.algorithm;
import std.conv;
import std.math;
import std.range;

import gl3n.aabb;
import gl3n.linalg;

import components.drawables.polygon;
import entity;
import systemset;


void updateDebugEntities(SystemSet systemSet)
{
  foreach (entityHandler; systemSet.entityHandlers)
  {
    assert(!entityHandler.debugTiming.isNaN);
    
    auto found = systemSet.entities.find!
                    (entity => entity.get("name", "") == entityHandler.className);
    
    if (!found.empty)
    {
      auto debugEntity = found.front;
      
      auto prevSize = debugEntity.get!double("size");
      auto size = prevSize * 0.9 + (0.3 + sqrt(entityHandler.debugTiming)*0.1) * 0.1;
      
      auto prevTimePerComponent = debugEntity.get!double("timePerComponent");
      auto timePerComponent = prevTimePerComponent * 0.9 + 
                              (entityHandler.debugTiming / entityHandler.componentCount) * 0.1;
      debugEntity["timePerComponent"] = timePerComponent;
      debugEntity["componentCount"] = entityHandler.componentCount;
      
      //assert("name" in debugEntity.values, debugEntity.values.to!string);
      //assert("size" in debugEntity.values, debugEntity.values.to!string);
      assert(debugEntity.has("name"));
      assert(debugEntity.has("size"));
      
      auto polygon = new Polygon(size, 16, vec4(timePerComponent, 0.67, 0.33, 1.0));
      debugEntity["size"] = size;
      //debugEntity["polygon.vertices"] = polygon.vertices;
      //debugEntity["polygon.colors"] = polygon.colors;
      debugEntity.polygon = polygon;
    }
  }
}

Entity[] makeSpatialTreeBoxes(AABB[][int] boxSet)
{
  Entity[] entities;
  
  foreach (level, boxes; boxSet)
  {
    auto levelColor = vec4(0.5, 1.0 / (cast(double)level).sqrt, 1.0 / cast(double)level, 0.1);
    foreach (box; boxes)
    {
      auto entity = new Entity();
      entity["position"] = vec3(0.0, 0.0, 0.0);
      entity["ToBeRemoved"] = true;
      
      import components.drawables.polygon;
      entity.polygon = new Polygon([vec3(box.min.x, box.min.y, -1.0), 
                                    vec3(box.min.x, box.max.y, -1.0), 
                                    vec3(box.max.x, box.min.y, -1.0), 
                                    vec3(box.min.x, box.max.y, -1.0), 
                                    vec3(box.max.x, box.max.y, -1.0), 
                                    vec3(box.max.x, box.min.y, -1.0)],
                                    levelColor.repeat.take(6).array);
      
      entities ~= entity;
    }
  }
  
  return entities;
}
