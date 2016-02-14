module systems.graphics;

import std.algorithm;
import std.array;
import std.datetime;
import std.stdio;

import gl3n.linalg;
import glamour.shader;
import glamour.texture;

import camera;
import converters;
import entityhandler;
import entity;
import system;


interface GraphicsHandler : EntityHandler
{
  vec3[][string] getVertices();
  vec2[][string] getTexCoords();
  vec4[][string] getColors();
  Texture2D[string] getTextureSet();
}

abstract class Graphics(ComponentType) : System!ComponentType, GraphicsHandler
{
  this(int xres, int yres)
  {
    this.xres = xres; 
    this.yres = yres;
  }

  override void close()
  {
    foreach (name, texture; textureSet)
      texture.remove();
  }
  
  immutable int xres, yres;
  
  vec3[][string] vertices;
  vec2[][string] texCoords;
  vec4[][string] colors;
  Texture2D[string] textureSet;
  
  vec3[][string] getVertices() { return vertices; }
  vec2[][string] getTexCoords() { return texCoords; }
  vec4[][string] getColors() { return colors; }
  Texture2D[string] getTextureSet() { return textureSet; }
  
  vec3[65536] verticesBuffer;
  vec2[65536] texCoordBuffer;
  vec4[65536] colorBuffer;
}

void fillBuffer(Type)(Type[] buffer, Type[] source, ref size_t index) @nogc
{
  buffer[index .. index + source.length] = source;
  index += source.length;
}

vec3 getWorldPositionFromScreenCoordinates(Camera camera, vec2 screenCoordinates, 
                                           int xres, int yres)
{
  return camera.transform(vec3(screenCoordinates.x / cast(float)xres - 0.5,
                               0.5 - screenCoordinates.y / cast(float)yres,
                               0.0));
}
