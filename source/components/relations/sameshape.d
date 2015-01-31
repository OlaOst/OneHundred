module components.relations.sameshape;

import std.conv;

import gl3n.aabb;

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
    assert("aabb" in target.values, 
           "Could not find AABB in target values: " ~ target.values.to!string);
    
    auto aabb = target.values["aabb"].myTo!AABB;
    source.values["polygon.vertices"] = [[aabb.min.x, aabb.min.y], 
                                         [aabb.min.x, aabb.max.y], 
                                         [aabb.max.x, aabb.min.y],
                                         [aabb.min.x, aabb.max.y], 
                                         [aabb.max.x, aabb.max.y], 
                                         [aabb.max.x, aabb.min.y]].to!string;
  }
}
