module spatialindex.spatialindex;

import gl3n.aabb;
import gl3n.linalg;


interface SpatialIndex(Element)
  if (__traits(compiles, function AABB (Element element) { return element.aabb; }))
{  
  Element[] find(AABB searchBox);
  void insert(Element element);
}

bool intersectsEquals(AABB first, AABB box) pure nothrow @nogc
{
  return (first.min.x <= box.max.x && first.max.x >= box.min.x) &&
         (first.min.y <= box.max.y && first.max.y >= box.min.y) &&
         (first.min.z <= box.max.z && first.max.z >= box.min.z);
}

AABB expanded(AABB left, AABB right)
{
  AABB result = left;
  result.expand(right);
  return result;
}

double circumfence(AABB aabb) 
{
  vec3 e = aabb.extent;
  return 2.0 * (e.x + e.y);
}
