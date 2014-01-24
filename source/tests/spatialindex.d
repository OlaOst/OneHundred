module tests.spatialindex;

import gl3n.linalg;

import spatialindex;


unittest
{
  struct Element
  {
    vec2 position;
    double radius;
  }
  
  auto index = new SpatialIndex!Element(1.0);
  
  //assert(index.findCoveringIndices(vec2(0.0, 0.0), 0.0)[0] == [1073741823, 1789569706, 2505397589, 3221225472]);
  //assert(index.findCoveringIndices(vec2(0.0, 0.0), 0.9999)[0] == [1073741823, 1789569706, 2505397589, 3221225472]);
  //assert(index.findCoveringIndices(vec2(0.0, 0.0), 1.0)[1] == [268435455, 447392426, 626349397, 805306368]);
  //assert(index.findCoveringIndices(vec2(0.0, 0.0), 1.5) == [1789569705, 1789569705, -1789569706, -1789569706]);
  //assert(index.findCoveringIndices(vec2(0.0, 0.0), 2.1) == [0, 1, 2, 3, 4, 6, 8, 9, 12]);
  
  
  //assert(index.find(vec2(0.0, 0.0), 2.0) == []);
  
  auto firstElement = Element(vec2(2.5, 2.5), 2.0);
  //index.insert(firstElement);
  //assert(index.find(vec2(0.0, 0.0), 2.0) == [firstElement]);
  //assert(index.find(vec2(10.0, 10.0), 2.0) == []);
  
  auto secondElement = Element(vec2(123.0, 1000.0), 12.3);
  //index.insert(secondElement);
  //assert(index.find(vec2(123.0, 2000.0), 500.0) == []);
  //assert(index.find(vec2(123.0, 1012.3), 0.1) == [secondElement]);
  
  index.find(vec2(0, 0), 32768);
  /+
  auto test1 = index.findCoveringIndices(vec2(16384.0, 16384.0), 4.0);
  auto test2 = index.findCoveringIndices(vec2(16384.0, 16384.0), 1.0);
  
  import std.algorithm;
  import std.stdio;
  import std.array;
  auto intersect0 = setIntersection(test1[0].sort, test2[0].sort);
  auto intersect1 = setIntersection(test1[1].sort, test2[1].sort);
  auto intersect2 = setIntersection(test1[2].sort, test2[2].sort);
  auto intersect3 = setIntersection(test1[3].sort, test2[3].sort);
  
  debug writeln("level 0 intersect between test1 with ", test1[0].length, " indices and test2 with ", test2[0].length, " indices: ", intersect0);
  debug writeln("level 1 intersect between test1 with ", test1[1].length, " indices and test2 with ", test2[1].length, " indices: ", intersect1);
  debug writeln("level 2 intersect between test1 with ", test1[2].length, " indices and test2 with ", test2[2].length, " indices: ", intersect2);
  debug writeln("level 3 intersect between test1 with ", test1[3].length, " indices and test2 with ", test2[3].length, " indices: ", intersect3);
  +/
  assert(false);
  
  //assert(index.find(vec2(0.1, 0.1), 10000.0) == [firstElement, secondElement], "Expected two elements, found " ~ index.find(vec2(0.1, 0.1), 10000.0).to!string);
}
