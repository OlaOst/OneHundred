module components.drawables.sprite;

import std.algorithm;
import std.conv;
import std.exception;
import std.range;
import std.string;

import glamour.texture;
import gl3n.linalg;

import components.drawable;


final class Sprite : Drawable
{
  double size;
  string fileName;
  Texture2D texture;
  // TODO: texcoords in case texture is a spritesheet or atlas

  static Texture2D[string] textureCache;
  
  vec2[] vertices;
  vec2[] texCoords;
  
  this(double size, string fileName)
  {
    this.size = size;
    this.fileName = fileName;
    
    if (fileName !in textureCache)
      textureCache[fileName] = Texture2D.from_image(fileName);
     
    texture = textureCache[fileName];
    
    // assume images point up by default.
    // since our default angle 0 is pointing to the right, 
    // we need to rotate the sprite 90 degrees clockwise
    vertices = baseSquare.dup.map!(vertex => (vec3(vertex, 0.0) * mat3.zrotation(PI/2)).xy * 
                                              size).array;
    texCoords = baseTexCoordsSquare.dup;
  }
  
  static bool canMakeComponent(string[string] values)
  {
    return "size" in values && "sprite" in values;
  }
}
