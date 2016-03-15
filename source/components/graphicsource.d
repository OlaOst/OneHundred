module components.graphicsource;

import std.algorithm;
import std.array;

import gl3n.aabb;
import gl3n.linalg;


class GraphicSource
{
  invariant
  {
    import std.stdio;
    scope(failure) writeln(sourceName);
    
    assert(vertices.length == colors.length);
    assert(colors.length == texCoords.length);
    
    assert(vertices.all!(vertex => vertex.isFinite));
    assert(texCoords.all!(texCoord => texCoord.isFinite));
    assert(colors.all!(color => color.isFinite));
    assert(position.isFinite);
    assert(!angle.isNaN);
    assert(size >= 0.0);
  }
  
  this(string sourceName, vec3 position, double angle, double size, 
       vec3[] vertices, vec2[] texCoords, vec4[] colors)
  out(result)
  {
    assert(this);
  }
  body
  {
    this.sourceName = sourceName;
    this.position = position;
    this.angle = angle;
    this.size = size;
    
    if (sourceName != "text")
    {
      // ensure normalized vertices
      auto furthestVertex = vertices.minCount!((a, b) => a.magnitude > b.magnitude)[0];
      this.vertices = vertices.map!(vertex => vertex / furthestVertex.magnitude).array;
    }
    else
    {
      this.vertices = vertices;
    }
    
    this.texCoords = texCoords;
    this.colors = colors;
  }
  
  @property transformedVertices()
  in
  {
    assert(this);
  }
  out(result)
  {
    assert(result.all!(vertex => vertex.isFinite));
  }
  body
  {
    return vertices.map!(vertex => vertex * mat3.zrotation(-angle) * size + position).array;
  }
  
  @property aabb()
  in
  {
    assert(this);
  }
  out(result)
  {
    assert(result.min.isFinite && result.max.isFinite);
  }
  body
  {    
    return AABB.from_points(transformedVertices);
  }
  
  string sourceName;
  
  vec3 position;
  double angle;
  
  double size = 1.0;
  
  vec3[] vertices;
  vec4[] colors;
  vec2[] texCoords;
}
