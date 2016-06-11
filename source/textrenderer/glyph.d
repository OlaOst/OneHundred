module textrenderer.glyph;

import std.range;
import std.stdio;

import derelict.freetype.ft;
import derelict.opengl3.gl3;
import gl3n.linalg;


struct Glyph
{
  FT_Bitmap bitmap;

  vec2 offset;
  vec2 advance;

  GLubyte[] data;
}

Glyph loadGlyph(FT_Face face, char letter, uint glyphSize)
{
  static uint colorComponents = 4;

  auto glyphWidth = glyphSize;
  auto glyphHeight = glyphSize;

  auto glyphIndex = FT_Get_Char_Index(face, letter);

  FT_Load_Glyph(face, glyphIndex, 0);
  FT_Render_Glyph(face.glyph, FT_RENDER_MODE_NORMAL);

  /*debug writeln("glyph ", letter > 32 ? letter : '?',
                ", buffer is ", face.glyph.bitmap.width, "x", face.glyph.bitmap.rows,
                ", pitch is ", face.glyph.bitmap.pitch,
                ", metric is ", face.glyph.metrics.width/64, "x", face.glyph.metrics.height/64,
                ", horizontal advance is ", face.glyph.metrics.horiAdvance/64,
                ", bearing is ", face.glyph.bitmap_left, "x", face.glyph.bitmap_top);*/

  Glyph glyph;

  glyph.data = new GLubyte[colorComponents * glyphWidth * glyphHeight];
  glyph.bitmap = face.glyph.bitmap;

  glyph.offset = vec2(face.glyph.bitmap_left / cast(float)glyphSize,
                      (face.glyph.bitmap_top - face.glyph.bitmap.rows) / cast(float)glyphSize);
  glyph.advance = vec2(face.glyph.advance.x / (64.0 * cast(float)glyphSize),
                       face.glyph.advance.y / (64.0 * cast(float)glyphSize));

  glyph.offset *= 2.0;
  glyph.advance *= 2.0;

  auto unalignedGlyph = face.glyph.bitmap.buffer;

  auto widthOffset = (glyphWidth - face.glyph.bitmap.width) / 2;
  auto heightOffset = (glyphHeight - face.glyph.bitmap.rows) / 2;

  for (auto y = 0; y < face.glyph.bitmap.rows; y++)
  {
    for (auto x = 0; x < face.glyph.bitmap.width; x++)
    {
      auto coord = (x + y*glyphWidth) * colorComponents;

      if (glyph.data.length <= coord + 3)
      {
        stderr.writeln("Out of bounds error when creating glyph texture for character ", letter);
        break;
      }

      // all colors the same = monochrome text by default
      // will be transparent on the edges with the antialiasing
      foreach (int colorIndex; iota(0, colorComponents))
        glyph.data[coord + colorIndex] = unalignedGlyph[x + (face.glyph.bitmap.rows - 1 - y) *
                                                        face.glyph.bitmap.width];
    }
  }

  return glyph;
}
