module spatialindex;

import std.algorithm;
import std.array;
import std.bitmanip;
import std.math;
import std.range;
import std.stdio;

import gl3n.aabb;
import gl3n.linalg;

import bitops;


// the purpose of the SpatialIndex is to answer which elements is within a given radius around a point
// elements must have a radius of type double and a position of type vec2
class SpatialIndex(Element)
  if (__traits(compiles, function double (Element element) { return element.radius; }) &&
      __traits(compiles, function vec2 (Element element) { return element.position; }))
{
  double leastQuadrantSize;
  
  enum uint levels = 17;
  
  Element[][uint][levels] elementsInIndex;
  
  this(double leastQuadrantSize)
  {
    this.leastQuadrantSize = leastQuadrantSize;
  }
  
  uint[][levels] findCoveringIndices(vec2 position, float radius)
  {
    uint[][levels] indices;
    
    auto object = AABB(vec3(position.x - radius, position.y - radius, -1.0), vec3(position.x + radius, position.y + radius, 1.0));
    auto quadrant = AABB(vec3(-2^^15, -2^^15, -1.0), vec3(2^^15, 2^^15, 1.0));
    
    //debug writeln("findCoveringIndices start");
    
    populateCoveringIndices(object, quadrant, indices);
    
    //debug writeln("findCoveringIndices found ", indices[0].length, " indices at level 0");
    
    return indices;
  } 
  
  // coveringindices - whole part is the index, fractional part is the level. 0 is minsize, .5 is next and so on
  void populateCoveringIndices(AABB object, AABB quadrant, ref uint[][levels] coveringIndices)
  {
    auto quadrantSize = (quadrant.extent.xy.magnitude_squared * 2).sqrt * 0.5;
    
    uint powerOf2(uint n)
    {
      uint level = 0;
      
      while (n > 1)
      {
        n >>= 1;
        level++;
      }
      return level;
    }
    auto level = powerOf2(cast(uint)quadrantSize);
    
    bool intersectsEquals(AABB first, AABB box) const 
    {
      return (first.min.x <= box.max.x && first.max.x >= box.min.x) &&
             (first.min.y <= box.max.y && first.max.y >= box.min.y) &&
             (first.min.z <= box.max.z && first.max.z >= box.min.z);
    }
    
    // add object to index if we're at bottom level and intersecting
    if (level == 0 && intersectsEquals(object, quadrant))
    {
      auto index = quadrant.min.xy.index;
      //debug writefln("adding index %032b for level %d", index, level);
      coveringIndices[level] ~= index;
    }
    
    // check subquads if we are not on the bottom level
    if (level > 0)
    {
      // if the object covers the entire quadrant there is no need to check subquadrants
      if (object.min.x < quadrant.min.x && 
          object.min.y < quadrant.min.y &&
          object.max.x > quadrant.max.x &&
          object.max.y > quadrant.max.y)
      {
        auto index = quadrant.min.xy.index >> level*2;
        if (level > 13) debug writefln("adding index %032b for level %d", index, level);
        coveringIndices[level] ~= index;
      }
      else
      {
        // check subquadrants and recurse
        
        auto middle = (quadrant.min + quadrant.max) * 0.5;
        
        auto lowerLeft = AABB(quadrant.min, vec3(middle.xy, 1.0));
        auto lowerRight = AABB(vec3(middle.x, quadrant.min.y, -1.0), vec3(quadrant.max.x, middle.y, 1.0));
        auto upperRight = AABB(vec3(middle.xy, -1.0), quadrant.max);
        auto upperLeft = AABB(vec3(quadrant.min.x, middle.y, -1.0), vec3(middle.x, quadrant.max.y, 1.0));
        
        assert(level >= 0 && level < coveringIndices.length, "level out of bounds [0.." ~ (levels-1).to!string ~ "]: " ~ level.to!string);
        
        //debug writeln("populateCoveringIndices(", object, ", ", quadrant, ", ", coveringIndices[level].length, "), size ", quadrantSize, ", level ", level);
        
        bool lowerLeftIntersects = intersectsEquals(object, lowerLeft);
        bool lowerRightIntersects = intersectsEquals(object, lowerRight);
        bool upperRightIntersects = intersectsEquals(object, upperRight);
        bool upperLeftIntersects = intersectsEquals(object, upperLeft);
        
        //debug writeln("lowerLeft  ", lowerLeft, " is covering ", object, ": ", lowerLeftIntersects);
        //debug writeln("lowerRight ", lowerRight, " is covering ", object, ": ", lowerRightIntersects);
        //debug writeln("upperRight ", upperRight, " is covering ", object, ": ", upperRightIntersects);
        //debug writeln("upperLeft  ", upperLeft, " is covering ", object, ": ", upperLeftIntersects);

        assert(lowerLeft.extent.xy.magnitude_squared < quadrant.extent.xy.magnitude_squared);
      
        if (lowerLeftIntersects)
        {
          populateCoveringIndices(object, lowerLeft, coveringIndices);
        }
        if (lowerRightIntersects)
        {
          populateCoveringIndices(object, lowerRight, coveringIndices);
        }
        if (upperLeftIntersects)
        {
          populateCoveringIndices(object, upperLeft, coveringIndices);
        }
        if (upperRightIntersects)
        {
          populateCoveringIndices(object, upperRight, coveringIndices);
        }
        
      }
    }
  }  
  
  Element[] find(vec2 position, double radius)
  in
  {
    assert(position.ok);
    assert(radius >= 0.0, "Cannot find something with negative radius");
  }
  body
  { 
    Element[] elements;

    auto coveringIndices = findCoveringIndices(position, radius);
    
    //debug writeln("find found ", coveringIndices);
    
    foreach (level, indices; coveringIndices)
      foreach (index; indices.filter!(index => index in elementsInIndex[level]))
        elements ~= elementsInIndex[level][index];
    
    return elements.sort.uniq.array;
  }
  
  void insert(Element element)
  in
  {
    assert(element.position.ok);
    assert(element.radius >= 0.0, "Cannot insert something with negative radius");
  }
  body
  {
    auto coveringIndices = findCoveringIndices(element.position, element.radius);

    foreach (level, indices; coveringIndices)
    {
      assert(level >= 0 && level < levels, "level out of bounds [0.." ~ (levels-1).to!string ~ "]: " ~ level.to!string);
    
      foreach (index; indices)
        elementsInIndex[level][index] ~= element;
    }
  }
}

// hash a position into an int
static uint index(vec2 position)
{
  // TODO: make sure values are clamped not wrapped
  
  //debug writeln("index for ", position, " -> ", [(cast(uint)position.x) + 2^^15, (cast(uint)position.y) + 2^^15], " is ", interleave(cast(uint)position.x + 2^^15, cast(uint)position.y + 2^^15));
  
  return interleave(cast(uint)position.x + 2^^15, cast(uint)position.y + 2^^15);
}
