module textrenderer.transform;

import std.algorithm;
import std.array;
import std.string;

import gl3n.linalg;

import components.drawable;
import components.drawables.text;
import textrenderer.textrenderer;


vec3[] getVerticesForText(TextRenderer textRenderer, string text, vec3 position, double angle, double size) //@nogc
{
  static vec3[65536] buffer;
  size_t index = 0;
  
  auto cursor = vec2(0.0, 0.0);

  size = 1.0;
  
  auto vertices = baseSquare.dup.map!(vertex => vertex * size).array;
  //auto vertices = baseSquare.dup;
  
  auto lines = text.splitter("\n");
  foreach (line; lines)
  {
    foreach (letter; line)
    {
      auto glyph = textRenderer.getGlyphForLetter(letter);
      
      foreach (vertex; vertices)
      {
        buffer[index] = (vertex * mat3.zrotation(-angle) + position) + 
                         vec3((glyph.offset * size + cursor), 0.0);
        index++;
      }
      
      cursor += glyph.advance * size;
    }
    cursor = vec2(0.0, cursor.y - size * 2.0);
  }
  
  return buffer[0..index];
}

vec2[] getTexCoordsForText(TextRenderer textRenderer, string text) @nogc
{
  auto lines = text.splitter("\n");
  
  auto letterCount = lines.map!(line => line.count).sum;
  static vec2[65536] buffer;
  
  assert(letterCount*6 < buffer.length);
  
  size_t index = 0;
  foreach (line; lines)
  {
    foreach (letter; line)
    {
      buffer[index*6 .. (index+1)*6] = textRenderer.getTexCoordsForLetter(letter);
      index++;
    }
  }
  
  return buffer[0..letterCount*6];
}
