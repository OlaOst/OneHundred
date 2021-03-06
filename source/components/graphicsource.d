module components.graphicsource;

import std;

import gl3n.aabb;
import gl3n.linalg;

import renderer.graphicsdata;


class GraphicSource
{
  invariant
  {
    scope(failure) writeln("invariant failed for GraphSource with sourceName ", sourceName);
    
    assert(data);
    assert(position.isFinite);
    assert(!angle.isNaN);
    assert(size >= 0.0);
  }
  
  this(string sourceName, vec3 position, double angle, double size, GraphicsData data)
  out(result) { assert(this); }
  do
  {
    this.sourceName = sourceName;
    this.position = position;
    this.angle = angle;
    this.size = size;
    
    this.data = data;
    
    if (sourceName != "text")
    {
      // ensure normalized vertices
      auto furthestVertex = data.vertices.minCount!((a, b) => a.magnitude > b.magnitude)[0];
      this.data.vertices = data.vertices.map!(vertex => vertex / furthestVertex.magnitude).array;
    }
  }
  
  auto transformedData()
  {
    return new GraphicsData(transformedVertices, transformedControlVertices, 
                            data.texCoords, data.colors);
  }
  
  auto transformedVertices()
  in { assert(this); }
  out(result)
  {
    assert(result.all!(vertex => vertex.isFinite));
  }
  do
  {
    return data.vertices.map!(vertex => vertex * mat3.zrotation(-angle) * size + position).array;
  }
  
  auto transformedControlVertices()
  in { assert(this); }
  out(result)
  {
    assert(result.all!(vertex => vertex.isFinite));
  }
  do
  {
    return data.controlVertices.map!(vertex => vertex * mat3.zrotation(-angle) 
                                                      * size + position).array;
  }
  
  auto aabb()
  in { assert(this); }
  out(result)
  {
    assert(result.min.isFinite && result.max.isFinite);
  }
  do
  {    
    return AABB.from_points(transformedVertices);
  }
  
  string sourceName;
  vec3 position;
  double angle;
  double size = 1.0;
  GraphicsData data;
}
