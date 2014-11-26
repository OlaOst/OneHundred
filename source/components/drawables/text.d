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
  vec4 color;
  
  this(double size, string text, vec4 color)
  {
    this.size = size;
    this.text = text;
    this.color = color;
    
    vertices = baseSquare.dup.map!(vertex => vertex * size).array;
  }
  
  static bool canMakeComponent(string[string] values)
  {
    return "text" in values && "size" in values && "color" in values;
  }
}
