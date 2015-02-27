module textrenderer.transform;

import std.algorithm;
import std.array;
import std.string;

import gl3n.linalg;

import camera;
import components.drawables.text;
import textrenderer.textrenderer;


vec3[] getVerticesForText(TextRenderer textRenderer, Text text, Camera camera) @nogc
{
  assert(camera !is null);
  
  static vec3[65536] buffer;
  size_t index = 0;
  
  auto cursor = vec2(0.0, 0.0);

  auto lines = text.text.splitter("\n");
  foreach (line; lines)
  {
    foreach (letter; line)
    {
      auto glyph = textRenderer.getGlyphForLetter(letter);
      
      foreach (vertex; text.vertices)
      {
        buffer[index] = (vertex * mat3.zrotation(-text.angle) + 
                         text.position - camera.position) * 
                        camera.zoom + vec3((glyph.offset * text.size + cursor), 0.0) * camera.zoom;
        index++;
      }
      
      cursor += glyph.advance * text.size;
    }
    cursor = vec2(0.0, cursor.y - text.size * 2.0);
  }
  
  return buffer[0..index];
}

vec2[] getTexCoordsForText(TextRenderer textRenderer, Text text) @nogc
{
  auto lines = text.text.splitter("\n");
  
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
