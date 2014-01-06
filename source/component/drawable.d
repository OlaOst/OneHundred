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
  
  float size;
  
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
  
  this(float size, vec3 color)
  {
    this.size = size;
    
    //this.vertices = this.baseTriangle.map!(vertex => vertex * size).array();
    //this.vertices = this.baseSquare.map!(vertex => vertex * size).array();
    
    auto points = uniform(3, 12);
    
    foreach (angle; iota(0.0, PI*2.0, PI*2.0/points))
    {
      auto nextangle = angle + (PI*2.0) / points;
      
      vertices ~= [vec2(0.0, 0.0), vec2(cos(angle), sin(angle)) * size, vec2(cos(nextangle), sin(nextangle)) * size];
      colors ~= [vec3(1.0, 1.0, 1.0), color, color];
    }
  }
}
