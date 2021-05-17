module textrenderer.textrenderer;

import std;

import bindbc.freetype;
import glamour.texture;
import gl3n.linalg;
import loader = bindbc.loader.sharedlib;

import textrenderer.atlas;
import textrenderer.glyph;


class TextRenderer
{
  this()
  {
    scope(failure) 
      loader.errors.each!(info => writeln(info.error.to!string, ": ", info.message.to!string));
    
    FTSupport loadedFreeTypeSupport = loadFreeType();
    if (loadedFreeTypeSupport != ftSupport)
    {
      enforce(loadedFreeTypeSupport != FTSupport.noLibrary, "Failed to load FreeType library");
      enforce(loadedFreeTypeSupport != FTSupport.badLibrary, "Error loading FreeType library");
    }

    FT_Library library;

    enforce(!FT_Init_FreeType(&library), "Error initializing FreeType");

    //auto defaultFont = "fonts/freesansbold.ttf";
    //auto defaultFont = "fonts/telegrama_render.otf";
    //auto defaultFont = "fonts/Inconsolata.otf";
    //auto defaultFont = "fonts/OxygenMono-Regular.otf";
    auto defaultFont = "fonts/Orbitron Black.otf";

    FT_Face face;
    auto fontError = FT_New_Face(library, ("./" ~ defaultFont).toStringz(), 0, &face);

    enforce(fontError != FT_Err_Unknown_File_Format,
            "Unrecognized font format when loading " ~ defaultFont);
    enforce(!fontError,
            "Error loading " ~ defaultFont ~ ": " ~ fontError.to!string);

    static enum uint glyphSize = 64;

    FT_Set_Pixel_Sizes(face, glyphSize, glyphSize);

    foreach (size_t index; iota(0, 256))
    //foreach (size_t index; iota(32, 128))
    {
      glyphSet[index/*.to!char*/] = face.loadGlyph(index.to!char, glyphSize);
    }

    atlas = glyphSet.createFontAtlas(defaultFont, glyphSize);
  }

  public void close()
  {
    if (atlas)
      atlas.remove();
  }

  public void bind()
  {
    atlas.bind_and_activate();
  }

  vec2[6] getTexCoordsForLetter(dchar letter) @nogc
  {
    int rows = cast(int)sqrt(cast(float)glyphSet.length);
    int cols = cast(int)sqrt(cast(float)glyphSet.length);

    int row = letter / rows;
    int col = letter % cols;

    float x1 = col / cast(float)rows;
    float y1 = row / cast(float)cols;

    float x2 = x1 + 1.0/cast(float)rows;
    float y2 = y1 + 1.0/cast(float)cols;

    return [vec2(x1, y1), vec2(x2, y1), vec2(x2, y2),
            vec2(x2, y2), vec2(x1, y2), vec2(x1, y1)];
  }

  public Glyph getGlyphForLetter(char letter) @nogc
  {
    return glyphSet[letter];
  }

  private static uint colorComponents = 4;
  private Glyph[256] glyphSet;
  public Texture2D atlas;
}
