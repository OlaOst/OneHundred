module component.drawables.text;

import std.conv;
import std.exception;
import std.string;

import derelict.freetype.ft;
import gl3n.linalg;

import component.drawable;


final class Text : Drawable
{
  double size;
  string text;
  
  alias text this;
  
  this(double size, string text, vec4 color)
  {
    this.size = size;
    this.text = text;
  }
}
