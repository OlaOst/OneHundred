module spatialindex.hilberthashimplementation;

import gl3n.aabb;
import gl3n.linalg;

import bitops;
import spatialindex.hilbertindex;


uint[][levels] findCoveringIndices(uint levels, uint maxIndicesPerLevel, uint minLevel)
                                  //(vec3 position, float radius, bool checkSubQuads)
                                  (AABB aabb, bool checkSubQuads)
{
  uint[][levels] indices;
  
  foreach (indicesForLevel; indices)
    indicesForLevel.length = maxIndicesPerLevel;
  
  //auto object = AABB(vec3(position.x-radius, position.y-radius, -1.0), 
                     //vec3(position.x+radius, position.y+radius, 1.0));
  auto quadrant = AABB(vec3(-2^^15, -2^^15, -1.0), vec3(2^^15, 2^^15, 1.0));
  
  populateCoveringIndices!(levels, maxIndicesPerLevel, minLevel)
                          //(object, quadrant, indices, checkSubQuads);
                          (aabb, quadrant, indices, checkSubQuads);
  
  return indices;
} 

void populateCoveringIndices(uint levels, uint maxIndicesPerLevel, uint minLevel)
                            (AABB object, AABB quadrant, 
                             ref uint[][levels] coveringIndices, bool checkSubQuads)
{
  auto level = powerOf2(cast(uint)quadrant.extent.x);
  
  // add object to index if we're at bottom level and intersecting
  if (level == minLevel && 
      intersectsEquals(object, quadrant) && 
      coveringIndices[level].length < maxIndicesPerLevel)
  {
    //auto index = quadrant.min.index >> level*2;
    auto index = quadrant.min.hilbertIndex >> level*2;
    coveringIndices[level] ~= index;
  }
  
  if (level > minLevel && coveringIndices[level].length < maxIndicesPerLevel)
  {
    auto fullyCovered = object.contains(quadrant);
    if (fullyCovered || (checkSubQuads && intersectsEquals(object, quadrant)))
    {
      //auto index = quadrant.min.index >> level*2;
      auto index = quadrant.min.hilbertIndex >> level*2;
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
        populateCoveringIndices!(levels, maxIndicesPerLevel, minLevel)
                                (object, lowerLeft, coveringIndices, checkSubQuads);
      if (intersectsEquals(object, lowerRight))
        populateCoveringIndices!(levels, maxIndicesPerLevel, minLevel)
                                (object, lowerRight, coveringIndices, checkSubQuads);
      if (intersectsEquals(object, upperLeft))
        populateCoveringIndices!(levels, maxIndicesPerLevel, minLevel)
                                (object, upperLeft, coveringIndices, checkSubQuads);
      if (intersectsEquals(object, upperRight))
        populateCoveringIndices!(levels, maxIndicesPerLevel, minLevel)
                                (object, upperRight, coveringIndices, checkSubQuads);
    }
  }
}
