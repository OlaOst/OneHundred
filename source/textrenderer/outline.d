module textrenderer.outline;

import std.algorithm;
import std.array;
import std.range;

import bindbc.freetype;
import gl3n.linalg;


struct Curve
{
  vec2 start;
  vec2 end;
  vec2[] controlPoints;
}

struct Contour
{
  vec2 pos;
  Curve[] curves;
}

struct Outline
{
  Contour[] contours;
}

Outline loadOutline(FT_Face face, char letter)
{
    auto glyphIndex = FT_Get_Char_Index(face, letter);
    FT_Load_Glyph(face, glyphIndex, 0);

    auto ftoutline = face.glyph.outline;

    import std.stdio;
    //writeln("outline: ", ftoutline);

    FT_BBox box;
    FT_Outline_Get_CBox(&ftoutline, &box);
    //writeln("control box: ", box);

    // pixelFormatScale from https://www.freetype.org/freetype2/docs/glyphs/glyphs-6.html
    auto pixelFormatScale = 64.0;
    auto scaleFactor = vec2(1.0 / (face.size.metrics.x_ppem * pixelFormatScale), 
                            1.0 / (face.size.metrics.y_ppem * pixelFormatScale));
    
    FT_Outline_Funcs decompFuncs;

    extern(C) FT_Outline_MoveToFunc moveTo = cast(FT_Outline_MoveToFunc)function(const FT_Vector* to, Outline* outline)
    {
      //debug writeln("moveTo ", *to);

      outline.contours ~= Contour();
      outline.contours[$-1].pos = vec2(to.x, to.y);

      return 0;
    };

    extern(C) auto lineTo = cast(FT_Outline_LineToFunc)function(const FT_Vector* to, Outline* outline)
    {
      //writeln("lineTo ", *to);

      auto currentPoint = outline.contours[$-1].pos;
      if (outline.contours[$-1].curves.length > 0)
        currentPoint = outline.contours[$-1].curves[$-1].end;

      auto nextPoint = vec2(to.x, to.y);

      outline.contours[$-1].curves ~= Curve(currentPoint, nextPoint, []);

      return 0;
    };

    extern(C) auto conicTo = cast(FT_Outline_ConicToFunc)function(const FT_Vector* control, const FT_Vector* to, Outline* outline)
    {
      //writeln("conicTo ", *to, " with control ", *control);

      auto currentPoint = outline.contours[$-1].pos;
      if (outline.contours[$-1].curves.length > 0)
        currentPoint = outline.contours[$-1].curves[$].end;

      auto nextPoint = vec2(to.x, to.y);

      outline.contours[$].curves ~= Curve(currentPoint, nextPoint, [vec2(control.x, control.y)]);
      currentPoint = nextPoint;

      return 0;
    };

    extern(C) auto cubicTo = cast(FT_Outline_CubicToFunc)function(const FT_Vector* control1, const FT_Vector* control2, const FT_Vector* to, Outline* outline)
    {
      //writeln("cubicTo ", *to, " with controls ", *control1, " and ", *control2);

      auto currentPoint = outline.contours[$-1].pos;
      if (outline.contours[$-1].curves.length > 0)
        currentPoint = outline.contours[$-1].curves[$-1].end;

      auto nextPoint = vec2(to.x, to.y);

      outline.contours[$-1].curves ~= Curve(currentPoint, nextPoint, [vec2(control1.x, control1.y), vec2(control2.x, control2.y)]);
      currentPoint = nextPoint;

      return 0;
    };

    decompFuncs.move_to = moveTo;
    decompFuncs.line_to = lineTo;
    decompFuncs.conic_to = conicTo;
    decompFuncs.cubic_to = cubicTo;
    decompFuncs.shift = 0;
    decompFuncs.delta = 0;

    Outline outline;

    FT_Outline_Decompose(&ftoutline, &decompFuncs, &outline);

    foreach (ref contour; outline.contours)
    { 
      contour.pos = vec2(contour.pos.x * scaleFactor.x, contour.pos.y * scaleFactor.y);
      foreach (ref curve; contour.curves)
      {
        curve.start = vec2(curve.start.x * scaleFactor.x, curve.start.y * scaleFactor.y);
        curve.end = vec2(curve.end.x * scaleFactor.x, curve.end.y * scaleFactor.y);
        foreach (ref point; curve.controlPoints)
        { 
          point = vec2(point.x * scaleFactor.x, point.y * scaleFactor.y);
        }
      }
    }
    
    return outline;
}
