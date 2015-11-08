module spatialindex.hilberthash;

import std.algorithm;
import std.array;
import std.bitmanip;
import std.range;
import std.stdio;

import gl3n.aabb;
import gl3n.linalg;

import bitops;

import spatialindex.hilberthashimplementation;
import spatialindex.spatialindex;


class HilbertHash(Element) : SpatialIndex!Element
  //if (__traits(compiles, function double (Element element) { return element.radius; }) &&
  //    __traits(compiles, function vec3 (Element element) { return element.position; })/* &&
  //    __traits(compiles, element.opCmp())*/)
{
  enum uint levels = 17;
  enum uint maxIndicesPerLevel = 2^^12;
  enum uint minLevel = 2; // quad extent at minlevel == 2^^minLevel
  //double leastQuadrantSize = 1.0;
  Element[][uint][levels] elementsInIndex;

  Element[] overlappingElements()
  {
    Element[] overlappingElements;
    
    // return all elements that overlap
    // start at top level
    auto indices = elementsInIndex[levels-1].keys
                   .filter!(index => elementsInIndex[levels-1][index].length >= 2)
                   .array;
    for (uint level = levels - 2; level >= minLevel; level--)
    {  
      indices = elementsInIndex[level].keys
                .filter!(index => elementsInIndex[level][index].length >= 2)
                .filter!(index => indices.canFind!(i => i == index >> 2))
                .array;
    }
    
    // TODO: should we check every level or is it enough with the bottom level?
    foreach (index; indices)
      overlappingElements ~= elementsInIndex[minLevel][index];
    
    return overlappingElements.sort().uniq.array;
  }
  
  /*Element[] find(vec3 position, double radius)
  in
  {
    assert(position.isFinite);
    assert(radius >= 0.0, "Cannot find something with negative radius");
  }
  body
  { 
  }*/
  
  Element[] find(AABB aabb)
  {
    Element[] elements;
    
    //import std.stdio;
    //writeln("hilberthash find with aabb ", aabb);
    
    foreach (level, indices; findCoveringIndices!(levels, maxIndicesPerLevel, minLevel)
                                                 (aabb, false))
      //foreach (index; indices.filter!(index => index in elementsInIndex[level]))
      foreach (index; indices)
        if (index in elementsInIndex[level])
          elements ~= elementsInIndex[level][index];
    
    return sort(elements).uniq.array;
  }
  
  void insert(Element element)
  /*in
  {
    assert(element.position.isFinite);
    assert(element.radius >= 0.0, "Cannot insert something with negative radius");
  }
  body*/
  {
    //foreach (level, indices; findCoveringIndices!(levels, maxIndicesPerLevel, minLevel)
                                                 //(element.position, element.radius, true))
    foreach (level, indices; findCoveringIndices!(levels, maxIndicesPerLevel, minLevel)
                                                 (element.aabb, true))
    {
      foreach (index; indices)
        elementsInIndex[level][index] ~= element;
    }
  }
}
