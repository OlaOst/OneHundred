module components.drawables.polygon;

import std.algorithm;
import std.array;
import std.range;

import gl3n.linalg;

import components.drawable;
import converters;


final class Polygon : Drawable
{  
  double size;
  
  vec3[] vertices;
  vec4[] colors;
  
  this (vec3[] vertices, vec4[] colors)
  {
    this.vertices = vertices;
    this.colors = colors;
  }
  
  this (vec3[] vertices, vec4 color)
  {
    this.vertices = vertices;
    this.colors = color.repeat(vertices.length).array;
  }
  
  this(double size, int points, vec4 color)
  {
    this.size = size;
    
    //this.vertices = this.baseTriangle.map!(vertex => vertex * size).array();
    //this.vertices = this.baseSquare.map!(vertex => vertex * size).array();
    
    foreach (angle; iota(0.0, PI*2.0, PI*2.0/points))
    {
      auto nextangle = angle + (PI*2.0) / points;
      
      vertices ~= [vec3(0.0, 0.0, 0.0), 
                   vec3(vec2FromAngle(angle) * size, 0.0), 
                   vec3(vec2FromAngle(nextangle) * size, 0.0)];
                   
      colors ~= [vec4(1.0, 1.0, 1.0, 1.0), color, color];
    }
  }
}

bool isClockwise(vec2 p1, vec2 p2, vec2 p3)
{
    return (p1.x*p2.y + p2.x*p3.y + p3.x*p1.y - 
            p2.x*p1.y - p3.x*p2.y - p1.x*p3.y) < 0;
}
