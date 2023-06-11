module components.relations.sameshape;

import std.conv;

import inmath.aabb;
import inmath.linalg;

import components.relation;
import converters;
import entity;


class SameShape : Relation
{
  Entity source;
  
  this(Entity source)
  {
    this.source = source;
  }
  
  void updateValues(Entity target)
  {
    assert(target.has("aabb"), 
           "Could not find AABB in target values");//: " ~ target.values.to!string);
    
    //import std.stdio;
    /+writeln("sameshape setting source ", source.id, 
              " shape from target ", target.get!string("text"), 
              " with aabb min x ", target.get!AABB("aabb").min.x, 
              " and position ", target.get!vec3("position").x);+/
    
    //auto aabb = target.values["aabb"].myTo!AABB;
    auto aabb = target.get!AABB("aabb");
    /*source["polygon.vertices"] = [[aabb.min.x, aabb.min.y], 
                                  [aabb.min.x, aabb.max.y], 
                                  [aabb.max.x, aabb.min.y],
                                  [aabb.min.x, aabb.max.y], 
                                  [aabb.max.x, aabb.max.y], 
                                  [aabb.max.x, aabb.min.y]];*/
    /*source.polygon.vertices = [vec2(aabb.min.x, aabb.min.y), 
                               vec2(aabb.min.x, aabb.max.y), 
                               vec2(aabb.max.x, aabb.min.y),
                               vec2(aabb.min.x, aabb.max.y), 
                               vec2(aabb.max.x, aabb.max.y), 
                               vec2(aabb.max.x, aabb.min.y)];*/
                     
    source["polygon.vertices"] = [vec3(aabb.min.x, aabb.min.y, 0.0), 
                                  vec3(aabb.min.x, aabb.max.y, 0.0), 
                                  vec3(aabb.max.x, aabb.min.y, 0.0),
                                  vec3(aabb.min.x, aabb.max.y, 0.0), 
                                  vec3(aabb.max.x, aabb.max.y, 0.0), 
                                  vec3(aabb.max.x, aabb.min.y, 0.0)];
    
    //source.polygon.position = target.get!vec3("position");
  }
}
