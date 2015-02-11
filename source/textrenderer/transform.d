module textrenderer.transform;

import std.algorithm;
import std.array;
import std.string;

import gl3n.linalg;

import camera;
import components.drawables.text;
import textrenderer.textrenderer;


vec2[] getVerticesForText(TextRenderer textRenderer, 
                          //Text text, double zoom, vec2 delegate (vec2) transform)
                          //Text text, double zoom, vec2 function (vec2, Text, Camera) @nogc transform) @nogc
                          Text text, Camera camera) @nogc
{
  //vec2[] result;
  vec2[65536] buffer;
  size_t index = 0;
  
  auto cursor = vec2(0.0, 0.0);

  //auto lines = text.text.split("\n");
  auto lines = text.text.splitter("\n");
  foreach (line; lines)
  {
    foreach (letter; line)
    {
      auto glyph = textRenderer.getGlyphForLetter(letter);
      //auto textTransform = delegate (vec2 vertex) => transform(vertex) + 
                                                     //(glyph.offset * text.size + cursor) * zoom;

      //result ~= text.vertices.map!textTransform.array();
      //auto textTransformedVertices = text.vertices.map!textTransform;
      //auto textTransformedVertices = text.vertices.map!(vertex => transform(vertex, text, null) + (glyph.offset * text.size + cursor) * zoom);
      
      foreach (vertex; text.vertices)
      {
        //vec3(vertex, 0.0)*mat3.zrotation(-component.angle)).xy + component.position - camera.position) * camera.zoom;
        buffer[index] = ((vec3(vertex, 0.0) * mat3.zrotation(-text.angle)).xy + text.position - camera.position) * camera.zoom + (glyph.offset * text.size + cursor) * camera.zoom;
      
        //buffer[index] = transform(vertex, text, null) + (glyph.offset * text.size + cursor) * zoom;
        index++;
      }
      
      //foreach (textTransformedVertex; textTransformedVertices)
        //result ~= textTransformedVertex;
      
      cursor += glyph.advance * text.size;
    }
    cursor = vec2(0.0, cursor.y - text.size * 2.0);
  }
  
  //return result;
  return buffer[0..index];
}

vec2[] getTexCoordsForText(TextRenderer textRenderer, Text text) @nogc
{
  //auto lines = text.text.split("\n");
  auto lines = text.text.splitter("\n");
  
  //import std.algorithm;
  //auto letterCount = reduce!((count, line) => count + line.length)(0, lines);
  auto letterCount = lines.map!(line => line.count).sum;
  static vec2[65536] buffer;
  
  assert(letterCount*6 < buffer.length);
  
  size_t index = 0;
  foreach (line; lines)
  {
    foreach (letter; line)
    {
      //result ~= textRenderer.getTexCoordsForLetter(letter);
      buffer[index*6 .. (index+1)*6] = textRenderer.getTexCoordsForLetter(letter);
      index++;
    }
  }
  
  return buffer[0..letterCount*6];
}
