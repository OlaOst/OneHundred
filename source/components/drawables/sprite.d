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

  vec3[] vertices;
  vec2[] texCoords;

  this(double size, string fileName, Texture2D texture)
  {
    this.size = size;
    this.fileName = fileName;

    this.texture = texture;

    // assume images point up by default.
    // since our default angle 0 is pointing to the right,
    // we need to rotate the sprite 90 degrees clockwise
    vertices = baseSquare.dup.map!(vertex => vertex * mat3.zrotation(PI/2) * size).array;
    texCoords = baseTexCoordsSquare.dup;
  }
}
