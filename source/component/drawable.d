module component.drawable;

import std.algorithm;
import std.array;

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
  vec3 color;
  
  this(float size, vec3 color)
  {
    this.size = size;
    
    //this.vertices = this.baseTriangle.map!(vertex => vertex * size).array();
    this.vertices = this.baseSquare.map!(vertex => vertex * size).array();
    this.color = color;
  }
}
