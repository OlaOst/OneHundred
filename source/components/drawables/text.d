module components.drawables.text;

import std.algorithm;
import std.conv;
import std.exception;
import std.range;
import std.string;

import derelict.freetype.ft;
import gl3n.linalg;

import components.drawable;


final class Text : Drawable
{
  double size;
  string text;
  
  alias text this;
  
  vec2[] vertices;
  
  this(double size, string text, vec4 color)
  {
    this.size = size;
    this.text = text;
    
    vertices = baseSquare.dup.map!(vertex => vertex * size).array;
  }
}
