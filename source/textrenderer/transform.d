module textrenderer.transform;

import std.algorithm;
import std.array;
import std.string;

import gl3n.linalg;

import renderer.baseshapes;
import textrenderer.textrenderer;


vec3[] getVerticesForText(TextRenderer textRenderer, string text) //@nogc
{
  static vec3[65536] buffer;
  size_t index = 0;
  
  auto cursor = vec2(0.0, 0.0);
  
  auto vertices = textSquare.dup;

  auto lines = text.splitter("\n");
  foreach (line; lines)
  {
    foreach (letter; line)
    {
      auto glyph = textRenderer.getGlyphForLetter(letter);
      
      foreach (vertex; vertices)
      {
        buffer[index] = vertex + vec3((glyph.offset * 0.5 + cursor), 0.0);
        index++;
      }
      
      cursor += glyph.advance * 0.5;
    }
    cursor = vec2(0.0, cursor.y - 1.0);
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
