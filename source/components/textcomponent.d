module components.textcomponent;

import std;

import gl3n.aabb;
import gl3n.linalg;

import renderer.graphicsdata;


class TextComponent
{
  invariant
  {
    scope(failure) writeln("invariant failed for Text");
    
    assert(data);
    assert(position.isFinite);
    assert(!angle.isNaN);
    assert(size >= 0.0);
  }
  
  this(string text, vec3 position, double angle, double size, GraphicsData data)
  out(result) { assert(this); }
  do
  {
    this.text = text;
    this.position = position;
    this.angle = angle;
    this.size = size;
    
    this.data = data;
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
  
  string text;
  vec3 position;
  double angle;
  double size = 1.0;
  GraphicsData data;
}
