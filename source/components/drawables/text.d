module components.drawables.text;

import std.algorithm;
import std.conv;
import std.exception;
import std.range;
import std.string;

import derelict.freetype.ft;
import gl3n.aabb;
import gl3n.linalg;

import components.drawable;


final class Text : Drawable
{
  double size;
  string text;
  
  alias text this;
  
  vec2[] vertices;
  vec4 color;
  
  AABB aabb;
  
  this(double size, string text, vec4 color)
  {
    this.size = size;
    this.text = text;
    this.color = color;
    
    vertices = baseSquare.dup.map!(vertex => vertex * size).array;
  }
}
