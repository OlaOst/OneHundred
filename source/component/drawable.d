module component.drawable;

import std.algorithm;
import std.array;
import std.math;
import std.random;
import std.range;

import artemisd.all;
import gl3n.linalg;


final class Drawable : Component
{
  mixin TypeDecl;
  
  double size;
  
  static immutable vec2[] baseTriangle = [vec2(-1.0, -1.0),
                                          vec2( 1.0, -1.0),
                                          vec2( 0.0,  1.0)];
                                          
  static immutable vec2[] baseSquare = [vec2(-1.0, -1.0),
                                        vec2( 1.0, -1.0),
                                        vec2( 1.0,  1.0),
                                        vec2( 1.0,  1.0),
                                        vec2(-1.0,  1.0),
                                        vec2(-1.0, -1.0)];
  
  vec2[] vertices;
  vec3[] colors;
  
  this(double size, int points, vec3 color)
  {
    this.size = size;
    
    //this.vertices = this.baseTriangle.map!(vertex => vertex * size).array();
    //this.vertices = this.baseSquare.map!(vertex => vertex * size).array();
    
    foreach (angle; iota(0.0, PI*2.0, PI*2.0/points))
    {
      auto nextangle = angle + (PI*2.0) / points;
      
      vertices ~= [vec2(0.0, 0.0), 
                   vec2(cos(angle), sin(angle)) * size, 
                   vec2(cos(nextangle), sin(nextangle)) * size];
                   
      colors ~= [vec3(1.0, 1.0, 1.0), color, color];
    }
  }
}

bool isClockwise(vec2 p1, vec2 p2, vec2 p3)
{
    return (p1.x*p2.y + p2.x*p3.y + p3.x*p1.y - 
            p2.x*p1.y - p3.x*p2.y - p1.x*p3.y) < 0;
}