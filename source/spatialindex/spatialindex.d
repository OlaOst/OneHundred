module spatialindex.spatialindex;

import std.algorithm;
import std.array;
import std.bitmanip;
import std.range;
import std.stdio;

import gl3n.aabb;
import gl3n.linalg;

import bitops;

import spatialindex.implementation;


class SpatialIndex(Element)
  if (__traits(compiles, function double (Element element) { return element.radius; }) &&
      __traits(compiles, function vec2 (Element element) { return element.position; }))
{
  enum uint levels = 17;
  enum uint maxIndicesPerLevel = 2^^12;
  enum uint minLevel = 2; // quad extent at minlevel == 2^^minLevel
  //double leastQuadrantSize = 1.0;
  Element[][uint][levels] elementsInIndex;

  Element[] find(vec2 position, double radius)
  in
  {
    assert(position.isFinite);
    assert(radius >= 0.0, "Cannot find something with negative radius");
  }
  body
  { 
    Element[] elements;
    
    foreach (level, indices; findCoveringIndices!(levels, maxIndicesPerLevel, minLevel)
                                                 (position, radius, false))
      foreach (index; indices.filter!(index => index in elementsInIndex[level]))
        elements ~= elementsInIndex[level][index];
    
    return elements.sort.uniq.array;
  }
  
  void insert(Element element)
  in
  {
    assert(element.position.isFinite);
    assert(element.radius >= 0.0, "Cannot insert something with negative radius");
  }
  body
  {
    foreach (level, indices; findCoveringIndices!(levels, maxIndicesPerLevel, minLevel)
                                                 (element.position, element.radius, true))
    {
      foreach (index; indices)
        elementsInIndex[level][index] ~= element;
    }
  }
}
