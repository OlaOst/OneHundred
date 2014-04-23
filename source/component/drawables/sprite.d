module component.drawables.sprite;

import std.algorithm;
import std.conv;
import std.exception;
import std.range;
import std.string;

import glamour.texture;
import gl3n.linalg;

import component.drawable;


final class Sprite : Drawable
{
  double size;
  //Texture2D texture;
  // TODO: texcoords in case texture is a spritesheet or atlas
  
  vec2[] vertices;
  
  this(double size, string fileName)
  {
    this.size = size;
    
    //texture = Texture2D.from_image(fileName);
    
    vertices = baseSquare.dup.map!(vertex => vertex * size).array;
  }
}
