module components.graphicsource;

import std;

import inmath.aabb;
import inmath.linalg;

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
  
  this(string sourceName, string positionRelativeTo, vec3 position, double angle, double size, GraphicsData data)
  out(result) { assert(this); }
  do
  {
    this.sourceName = sourceName;
    this.positionRelativeTo = positionRelativeTo;
    this.position = position;
    this.angle = angle;
    this.size = size;
    
    this.data = data;
    
    if (sourceName != "text")
    {
      // ensure normalized vertices
      auto furthestVertex = data.vertices.minCount!((a, b) => a.length > b.length)[0];
      this.data.vertices = data.vertices.map!(vertex => vertex / furthestVertex.length).array;
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
    return data.vertices.map!(vertex => vertex * mat3.zRotation(-angle) * size + position).array;
  }
  
  auto transformedControlVertices()
  in { assert(this); }
  out(result)
  {
    assert(result.all!(vertex => vertex.isFinite));
  }
  do
  {
    return data.controlVertices.map!(vertex => vertex * mat3.zRotation(-angle) 
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
    return AABB.fromPoints(transformedVertices);
  }
  
  string sourceName;
  string positionRelativeTo;
  vec3 position;
  double angle;
  double size = 1.0;
  GraphicsData data;
}
