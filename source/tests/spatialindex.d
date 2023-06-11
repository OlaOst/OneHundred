module tests.spatialindex;

import inmath.linalg;

import spatialindex.spatialindex;


unittest
{
  struct Element
  {
    vec3 position;
    double radius;
  }
  
  /+auto index = new SpatialIndex!Element();
  
  assert(index.find(vec3(0.0, 0.0, 0.0), 2.0) == []);
  
  auto firstElement = Element(vec3(2.5, 2.5, 0.0), 2.0);
  index.insert(firstElement);
  assert(index.find(vec3(0.0, 0.0, 0.0), 2.0) == [firstElement]);
  assert(index.find(vec3(10.0, 10.0, 0.0), 2.0) == []);
  
  auto secondElement = Element(vec3(123.0, 1000.0, 0.0), 12.3);
  index.insert(secondElement);
  assert(index.find(vec3(123.0, 2000.0, 0.0), 500.0) == []);
  assert(index.find(vec3(123.0, 1012.3, 0.0), 0.1) == [secondElement]);
  
  assert(index.find(vec3(0.0, 0.0, 0.0), 1050.0) == [firstElement, secondElement]);+/
}
