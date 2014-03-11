module textrenderer.atlas;

import std.conv;
import std.range;
import std.stdio;

import derelict.opengl3.gl3;
import gl3n.linalg;
import glamour.texture;

import textrenderer.glyph;


Texture2D createFontAtlas(Glyph[char] glyphSet, string font, uint glyphSize)
{
  static uint colorComponents = 4;

  GLubyte[] data;
  
  //int rows = 16;
  //int cols = 16;
  int rows = cast(int)sqrt(cast(float)glyphSet.length);
  int cols = cast(int)sqrt(cast(float)glyphSet.length);
  
  // TODO: figure out all the magic numbers, replace with descriptive variables
  data.length = ((rows * glyphSize) * (cols * glyphSize) * colorComponents) + 
                (cols * glyphSize * colorComponents * colorComponents);
  
  // directly iterating the glyphSet is bad since associative arrays do not specify the order
  // letters must be put in a specified order in the atlas to be able to retrieve them later
  //foreach (index; iota(0, 256))
  foreach (uint index, char letter; glyphSet.keys)
  {
    auto glyph = glyphSet[letter];
    
    int row = index / rows;
    int col = index % cols;
    
    foreach (y; iota(0, glyphSize))
    {
      foreach (x; iota(0, glyphSize))
      {
        foreach (int colorIndex; iota(0, colorComponents))
        {
          data[colorComponents + 
               (colorComponents*cols*glyphSize) + 
               (col*glyphSize + 
                row*glyphSize*cols*glyphSize + x + y*glyphSize*rows)*colorComponents + 
               colorIndex] = glyph.data[(y * glyphSize + x)*colorComponents + colorIndex];
        }
      }
    }
  }
  
  auto texture = new Texture2D();
  texture.set_data(data, GL_RGBA, cols*glyphSize, rows*glyphSize, GL_RGBA, GL_UNSIGNED_BYTE);
  
  return texture;
}
