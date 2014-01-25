module tests.spatialindex;

import gl3n.linalg;

import spatialindex.spatialindex;


unittest
{
  struct Element
  {
    vec2 position;
    double radius;
  }
  
  auto index = new SpatialIndex!Element();
  
  assert(index.find(vec2(0.0, 0.0), 2.0) == []);
  
  auto firstElement = Element(vec2(2.5, 2.5), 2.0);
  index.insert(firstElement);
  assert(index.find(vec2(0.0, 0.0), 2.0) == [firstElement]);
  assert(index.find(vec2(10.0, 10.0), 2.0) == []);
  
  auto secondElement = Element(vec2(123.0, 1000.0), 12.3);
  index.insert(secondElement);
  assert(index.find(vec2(123.0, 2000.0), 500.0) == []);
  assert(index.find(vec2(123.0, 1012.3), 0.1) == [secondElement]);
  
  assert(index.find(vec2(0.0, 0.0), 1050.0) == [firstElement, secondElement]);
}
