module spatialindex.implementation;

import gl3n.aabb;
import gl3n.linalg;

import bitops;


uint[][levels] findCoveringIndices(uint levels, uint maxIndicesPerLevel)
                                  (vec2 position, float radius, bool checkSubQuads)
{
  uint[][levels] indices;
  
  auto object = AABB(vec3(position.x-radius, position.y-radius, -1.0), 
                     vec3(position.x+radius, position.y+radius, 1.0));
  auto quadrant = AABB(vec3(-2^^15, -2^^15, -1.0), vec3(2^^15, 2^^15, 1.0));
  
  populateCoveringIndices!(levels, maxIndicesPerLevel)(object, quadrant, indices, checkSubQuads);
  
  return indices;
} 

void populateCoveringIndices(uint levels, uint maxIndicesPerLevel)
                            (AABB object, AABB quadrant, 
                             ref uint[][levels] coveringIndices, bool checkSubQuads)
{
  auto level = powerOf2(cast(uint)quadrant.extent.x);
  
  // add object to index if we're at bottom level and intersecting
  if (level == 0 && 
      intersectsEquals(object, quadrant) && 
      coveringIndices[level].length < maxIndicesPerLevel)
  {
    auto index = quadrant.min.xy.index;
    coveringIndices[level] ~= index;
  }
  
  if (level > 0 && coveringIndices[level].length < maxIndicesPerLevel)
  {
    auto fullyCovered = object.contains(quadrant);
    if (fullyCovered || (checkSubQuads && intersectsEquals(object, quadrant)))
    {
      auto index = quadrant.min.xy.index >> level*2;
      coveringIndices[level] ~= index;
    }
    
    if (!fullyCovered || checkSubQuads)
    {
      // check subquadrants and recurse
      auto middle = (quadrant.min + quadrant.max) * 0.5;
      
      auto lowerLeft = AABB(quadrant.min, vec3(middle.xy, 1.0));
      auto lowerRight = AABB(vec3(middle.x, quadrant.min.y, -1.0), 
                             vec3(quadrant.max.x, middle.y, 1.0));
      auto upperRight = AABB(vec3(middle.xy, -1.0), quadrant.max);
      auto upperLeft = AABB(vec3(quadrant.min.x, middle.y, -1.0), 
                            vec3(middle.x, quadrant.max.y, 1.0));
              
      if (intersectsEquals(object, lowerLeft))
        populateCoveringIndices!(levels, maxIndicesPerLevel)
                                (object, lowerLeft, coveringIndices, checkSubQuads);
      if (intersectsEquals(object, lowerRight))
        populateCoveringIndices!(levels, maxIndicesPerLevel)
                                (object, lowerRight, coveringIndices, checkSubQuads);
      if (intersectsEquals(object, upperLeft))
        populateCoveringIndices!(levels, maxIndicesPerLevel)
                                (object, upperLeft, coveringIndices, checkSubQuads);
      if (intersectsEquals(object, upperRight))
        populateCoveringIndices!(levels, maxIndicesPerLevel)
                                (object, upperRight, coveringIndices, checkSubQuads);
    }
  }
}
