module textrenderer;

import std.conv;
import std.exception;
import std.range;
import std.stdio;
import std.string;

import derelict.freetype.ft;
import derelict.opengl3.gl3;
import glamour.texture;
import gl3n.linalg;


// TODO: freetype init stuff should be in dedicated module not in component module
class TextRenderer
{
  this()
  {
    DerelictFT.load();
    
    FT_Library library;
    
    enforce(!FT_Init_FreeType(&library), "Error initializing FreeType");
    
    auto defaultFont = "fonts/freesansbold.ttf";
    
    FT_Face face;
    auto fontError = FT_New_Face(library, ("./" ~ defaultFont).toStringz(), 0, &face);
    
    enforce(fontError != FT_Err_Unknown_File_Format, "Unrecognized font format when loading " ~ defaultFont);
    enforce(!fontError, "Error loading " ~ defaultFont ~ ": " ~ fontError.to!string);
    
    static enum glyphSize = 32;
    
    FT_Set_Pixel_Sizes(face, glyphSize, glyphSize);
    
    createFontAtlas(face, defaultFont, glyphSize);
  }

  public void close()
  {
    if (texture)
      texture.remove();
  }

  public void bind()
  {
    texture.bind_and_activate();
  }
  
  void createFontAtlas(FT_Face face, string font, uint glyphSize)
  {
    GLubyte[] data;
    
    // TODO: figure out all the magic numbers, replace with descriptive variables
    data.length = ((16 * glyphSize) ^^ 2) * colorComponents + (16 * glyphSize * colorComponents * colorComponents);
    
    foreach (index; iota(0, 256))
    {
      auto glyph = loadGlyph(face, glyphSize, index.to!char);
      
      int row = index / 16;
      int col = index % 16;
      
      foreach (y; iota(0, glyphSize))
      {
        foreach (x; iota(0, glyphSize))
        {
          foreach (int colorIndex; iota(0, colorComponents))
          {
            data[4 + (4*16*glyphSize) + (col*glyphSize + row*glyphSize*16*glyphSize + x + y*glyphSize*16)*4 + colorIndex] = glyph.data[(y * glyphSize + x)*4 + colorIndex];
          }
        }
      }
    }
    
    texture = new Texture2D();
    texture.set_data(data, GL_RGBA, 16*glyphSize, 16*glyphSize, GL_RGBA, GL_UNSIGNED_BYTE);
  }

  GlyphData loadGlyph(FT_Face face, uint glyphSize, char letter)
  {
    auto glyphWidth = glyphSize;
    auto glyphHeight = glyphSize;
    
    auto glyphIndex = FT_Get_Char_Index(face, letter);
    
    FT_Load_Glyph(face, glyphIndex, 0);
    FT_Render_Glyph(face.glyph, FT_RENDER_MODE_NORMAL);
    
    debug writeln("glyph ", letter, 
                  ", buffer is ", face.glyph.bitmap.width, "x", face.glyph.bitmap.rows,
                  ", pitch is ", face.glyph.bitmap.pitch,
                  ", metric is ", face.glyph.metrics.width/64, "x", face.glyph.metrics.height/64,
                  ", horizontal advance is ", face.glyph.metrics.horiAdvance/64, 
                  ", bearing is ", face.glyph.bitmap_left, "x", face.glyph.bitmap_top);
    
    GlyphData glyph;
    
    glyph.data = new GLubyte[4 * glyphWidth * glyphHeight];
    glyph.bitmap = face.glyph.bitmap;
    
    glyph.offset = vec2(face.glyph.bitmap_left / cast(float)glyphSize, (face.glyph.bitmap_top - face.glyph.bitmap.rows) / cast(float)glyphSize);
    glyph.advance = vec2(face.glyph.advance.x / (64.0 * cast(float)glyphSize), face.glyph.advance.y / (64.0 * cast(float)glyphSize));
    
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
        
        // all colors the same = monochrome text by default, should be transparent on the edges with the antialiasing
        foreach (int colorIndex; iota(0, colorComponents))
          glyph.data[coord + colorIndex] = unalignedGlyph[x + (face.glyph.bitmap.rows - 1 - y) * face.glyph.bitmap.width];
      }
    }
    
    return glyph;
  }

  struct GlyphData
  {
    FT_Bitmap bitmap;
    
    vec2 offset;
    vec2 advance;
    
    GLubyte[] data;
  }
  
  static uint colorComponents = 4;
  Texture2D texture;
}
