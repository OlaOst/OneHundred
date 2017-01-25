module renderer.graphicsdata;

import std.algorithm;
import std.range;

import gl3n.linalg;


class GraphicsData
{
  invariant
  {
    import std.conv;
    assert(vertices.length == colors.length, 
           vertices.length.to!string ~ " vertices vs " ~ colors.length.to!string ~ " colors");
    assert(vertices.length == texCoords.length);
    
    assert(vertices.all!(vertex => vertex.isFinite));
    assert(texCoords.all!(texCoord => texCoord.isFinite));
    assert(colors.all!(color => color.isFinite));
  }
  
  this() {}
  
  this(vec3[] vertices, vec2[] texCoords)
  {
    this.vertices = vertices;
    this.texCoords = texCoords;
    this.colors = vec4(0).repeat(vertices.length).array;
  }
  
  this(vec3[] vertices, vec4[] colors)
  {
    this.vertices = vertices;
    this.texCoords = vec2(0).repeat(vertices.length).array;
    this.colors = colors;
  }
  
  this(vec3[] vertices, vec3[] controlVertices, vec4[] colors)
  {
    this.vertices = vertices;
    this.controlVertices = controlVertices;
    this.texCoords = vec2(0).repeat(vertices.length).array;
    this.colors = colors;
  }
  
  this(vec3[] vertices, vec4 color)
  {
    this.vertices = vertices;
    this.texCoords = vec2(0).repeat(vertices.length).array;
    this.colors = color.repeat(vertices.length).array;
  }
  
  this(vec3[] vertices, vec2[] texCoords, vec4[] colors)
  {
    this.vertices = vertices;
    this.texCoords = texCoords;
    this.colors = colors;
  }
  
  this(vec3[] vertices, vec3[] controlVertices, vec2[] texCoords, vec4[] colors)
  {
    this.vertices = vertices;
    this.controlVertices = controlVertices;
    this.texCoords = texCoords;
    this.colors = colors;
  }
  
  void setColor(vec4 color)
  {
    colors = color.repeat(vertices.length).array;
  }
  
  vec3[] vertices;
  vec3[] controlVertices;
  vec4[] colors;
  vec2[] texCoords;
}
