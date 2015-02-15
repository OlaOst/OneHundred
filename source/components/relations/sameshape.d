module components.relations.sameshape;

import std.conv;

import gl3n.aabb;
import gl3n.linalg;

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
    
    //auto aabb = target.values["aabb"].myTo!AABB;
    auto aabb = target.get!AABB("aabb");
    /*source["polygon.vertices"] = [[aabb.min.x, aabb.min.y], 
                                  [aabb.min.x, aabb.max.y], 
                                  [aabb.max.x, aabb.min.y],
                                  [aabb.min.x, aabb.max.y], 
                                  [aabb.max.x, aabb.max.y], 
                                  [aabb.max.x, aabb.min.y]];*/
    import std.stdio;
    writeln("setting polygonverts from\n", [source.polygon.vertices[0], source.polygon.vertices[4]], "\nto\n", [aabb.min.xy, aabb.max.xy]);
    source.polygon.vertices = [vec2(aabb.min.x, aabb.min.y), 
                               vec2(aabb.min.x, aabb.max.y), 
                               vec2(aabb.max.x, aabb.min.y),
                               vec2(aabb.min.x, aabb.max.y), 
                               vec2(aabb.max.x, aabb.max.y), 
                               vec2(aabb.max.x, aabb.min.y)];
  }
}
