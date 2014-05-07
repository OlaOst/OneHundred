module textrenderer.transform;

import std.algorithm;
import std.array;
import std.string;

import gl3n.linalg;

import components.drawables.text;
import textrenderer.textrenderer;


vec2[] getVerticesForText(TextRenderer textRenderer, 
                          Text text, double zoom, vec2 delegate (vec2) transform)
{
  vec2[] result;
  
  auto cursor = vec2(0.0, 0.0);
        
  auto lines = text.text.split("\n");
  foreach (line; lines)
  {
    foreach (letter; line)
    {
      auto glyph = textRenderer.getGlyphForLetter(letter);
      auto textTransform = delegate (vec2 vertex) => transform(vertex) + 
                                                     (glyph.offset * text.size + cursor) * zoom;

      //result ~= text.vertices.map!textTransform.array();
      auto textTransformedVertices = text.vertices.map!textTransform;
      foreach (textTransformedVertex; textTransformedVertices)
        result ~= textTransformedVertex;
      
      cursor += glyph.advance * text.size * 2.0;
    }
    cursor = vec2(0.0, cursor.y - text.size * 2.0);
  }
  
  return result;
}

vec2[] getTexCoordsForText(TextRenderer textRenderer, Text text)
{
  vec2[] result;

  auto lines = text.text.split("\n");
  foreach (line; lines)
  {
    foreach (letter; line)
    {
      result ~= textRenderer.getTexCoordsForLetter(letter);
    }
  }
  
  return result;
}
