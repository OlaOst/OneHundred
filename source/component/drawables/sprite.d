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
  string fileName;
  Texture2D texture;
  // TODO: texcoords in case texture is a spritesheet or atlas

  static Texture2D[string] textureCache;
  
  vec2[] vertices;
  
  this(double size, string fileName)
  {
    this.size = size;
    this.fileName = fileName;
    
    if (fileName !in textureCache)
      textureCache[fileName] = Texture2D.from_image(fileName);
     
    texture = textureCache[fileName];
    
    vertices = baseSquare.dup.map!(vertex => vertex * size).array;
  }
}
