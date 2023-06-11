module debugentities;

import std.algorithm;
import std.conv;
import std.math;
import std.range;

import inmath.aabb;
import inmath.linalg;

import entity;
import renderer.polygon;
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
      
      debugEntity["graphicsource"] = "polygon";
      auto polygon = new Polygon(size, 16, vec4(timePerComponent, 0.67, 0.33, 1.0));
      debugEntity["size"] = size;
      debugEntity["polygon.vertices"] = polygon.vertices;
      debugEntity["polygon.colors"] = polygon.colors;
      //debugEntity.polygon = polygon;
    }
  }
}

Entity[] makeSpatialTreeBoxes(AABB[][int] boxSet)
{
  Entity[] entities;
  
  foreach (level, boxes; boxSet)
  {
    auto fixLevel = max(1, level);
    auto levelColor = vec4(0.5, 1.0 / (cast(double)fixLevel).sqrt, 1.0 / cast(double)fixLevel, 0.1);
    assert(levelColor.isFinite);
    
    foreach (box; boxes)
    {
      auto entity = new Entity();
      entity["position"] = box.center; //vec3(0.0, 0.0, 0.0);
      entity["ToBeRemoved"] = true;
      
      entity["graphicsource"] = "polygon";
      auto polygon = new Polygon([vec3(box.min.x, box.min.y, -1.0), 
                                  vec3(box.min.x, box.max.y, -1.0), 
                                  vec3(box.max.x, box.min.y, -1.0), 
                                  vec3(box.min.x, box.max.y, -1.0), 
                                  vec3(box.max.x, box.max.y, -1.0), 
                                  vec3(box.max.x, box.min.y, -1.0)],
                                  levelColor.repeat.take(6).array);
      
      entity["polygon.vertices"] = polygon.vertices.map!(vertex => vertex - box.center);
      entity["polygon.colors"] = polygon.colors;
      entity["size"] = box.extent.length * 0.5;
      
      entities ~= entity;
    }
  }
  
  return entities;
}
