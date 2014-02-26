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
  
  this(double size, string text, vec3 color)
  {
    this.size = size;
    this.text = text;
  }
}
