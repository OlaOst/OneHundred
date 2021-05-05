module systems.graphics;

import std;

import gl3n.linalg;
import glamour.shader;
import glamour.texture;

import camera;
import components.graphicsource;
import entity;
import renderer.baseshapes;
import renderer.graphicsblob;
import renderer.graphicsdata;
import renderer.renderer;
import textrenderer.textrenderer;
import textrenderer.transform;
import system;


class Graphics : System!GraphicSource
{
  this(Renderer renderer, TextRenderer textRenderer, Camera camera, Texture2D[string] textures)
  {
    this.shaders["coloredtexture"] = new Shader("shaders/coloredtexture.shader");
    this.shaders["textoutline"] = new Shader("shaders/textoutline.shader");
    this.shaders["textquadratic"] = new Shader("shaders/textquadratic.shader");

    this.textures = textures;
    this.renderer = renderer;
    this.textRenderer = textRenderer;
    this.camera = camera;
  }

  override void close()
  {
    blobs.byValue.each!(blob => blob.texture.remove());
  }

  bool canAddEntity(Entity entity)
  {
    return entity.has("graphicsource");
  }

  override void tweakEntity(ref Entity entity)
  {
    if ("text" in entity.values)
    {
      entity["text"] = entity["text"].replace("\\n", "\n");
    }
  }
  
  GraphicSource makeComponent(Entity entity)
  {
    auto source = entity.get!string("graphicsource");

    if (source !in textures)
    {
      // these sources should have been preloaded in the textures from the constructor
      assert(source != "polygon" && source != "text" && source != "textoutline");
      textures[source] = Texture2D.from_image(source);
    }
    if (source !in blobs)
      blobs[source] = new GraphicsBlob(textures[source]);

    GraphicsData data;
    if (source == "polygon")
    {
      if (entity.has("polygon.colors"))
        data = new GraphicsData(entity.get!(vec3[])("polygon.vertices"), entity.get!(vec4[])("polygon.colors"));
      else
        data = new GraphicsData(entity.get!(vec3[])("polygon.vertices"), entity.get!vec4("color"));
    }
    else if (source == "text")
      data = textRenderer.getGraphicsData(entity.get!string("text"), entity.get!vec4("color"));
    else if (source == "textoutline")
    {
      auto text = entity.get!string("text");
      auto cursor = vec2(0,0);
      vec3[] vertices;
      vec4[] colors;
      vec3[] controlVertices;
      
      auto lines = text.splitter("\n");
      foreach (line; lines)
      {
        foreach (letter; line)
        {
          auto outline = textRenderer.outlineSet[letter];
          auto glyph = textRenderer.getGlyphForLetter(letter);
          
          auto letterVertices = outline.contours.map!(contour => contour.curves.map!(curve => [vec3(0,0,0), vec3(curve.start,0), vec3(curve.end,0)]).joiner.array)
                                                .map!(vertices => vertices ~ [vec3(0,0,0), vertices[$-1], vertices[0]])
                                                .joiner;

          if (letterVertices.empty)
            continue;

          auto normalizedLetterVertices = letterVertices.map!(vertex => vertex + vec3((glyph.offset * 0.0 + cursor), 0.0))
                                                        .array;

          auto letterControlVertices = outline.contours.map!(contour => contour.curves.map!(curve => [vec3(curve.start,0), vec3(curve.end,0), vec3(curve.controlPoints.length > 0 ? curve.controlPoints[0] : (curve.start+curve.end)*0.5,0)]).joiner.array)
          //auto letterControlVertices = outline.contours.map!(contour => contour.curves.map!(curve => [vec3(curve.start,0), vec3(curve.end,0), vec3(curve.controlPoints.length > 0 ? curve.controlPoints[0] : vec2(0,0) ,0)]).joiner.array)
          //auto letterControlVertices = outline.contours.map!(contour => contour.curves.map!(curve => [vec3(curve.controlPoints.length > 0 ? curve.controlPoints[0] : vec2(0,0) ,0), vec3(curve.start,0), vec3(curve.end,0)]).joiner.array)
                                                       //.map!(vertices => vertices ~ [vec3(0,0,0), vertices[$-1], vertices[0]])
                                                       .joiner;
          auto normalizedLetterControlVertices = letterControlVertices.map!(vertex => vertex + vec3((glyph.offset * 0.0 + cursor), 0.0))
                                                                      .array;
                                                        
          cursor += glyph.advance * 0.5;
          
          import std.stdio;
          debug writeln("drawing ", letter, " at cursor ", cursor, " with glyph offset ", glyph.offset);
          debug writeln("letter vertices: ");
          debug std.range.chunks(normalizedLetterVertices, 3).each!writeln;
          debug writeln("controlvertices: ");
          debug std.range.chunks(normalizedLetterControlVertices, 3).each!writeln;
          //auto vertices = outline.contours[0].curves.map!(curve => [vec3(0,0,0), vec3(curve.start,0), vec3(curve.end,0)]).joiner.array;
          //vertices ~= [vec3(0,0,0), vertices[$-1], vertices[0]];
          
          auto letterColors = vec4(1,1,1,1).repeat.take(normalizedLetterVertices.length).array;
          
          //float red = 0.0;
          //auto colors = outline.contours[0].curves.map!(curve => [vec4(1-red,1,1,0), vec4(red,0,0.5,1), vec4(red+=1.0/outline.contours[0].curves.length,0,0.5,1)]).joiner.array;
          //auto colors = outline.contours[0].curves.map!(curve => [vec4(1,1,1,1), vec4(1,1,1,1), vec4(1,1,1,1)]).joiner.array;
          //colors ~= [vec4(1,1,1,0), colors[$-1], colors[0]];
          //auto vertices = outline.contours[0].curves.map!(curve => curve.start).array;
          //vertices ~= outline.contours[0].curves[$-1].end;
          
          vertices ~= normalizedLetterVertices;
          controlVertices ~= normalizedLetterControlVertices;
          colors ~= letterColors;
        }
        cursor = vec2(0.0, cursor.y - 1.0);
      }
      data = new GraphicsData(vertices, controlVertices, colors);
    }
    else
      data = new GraphicsData(baseSquare.dup.map!(vertex => vertex * mat3.zrotation(PI/2)).array, baseTexCoordsSquare.dup);

    auto position = entity.get!vec3("position");
    auto angle = entity.get!double("angle", entity.get!float("angle"));
    assert(entity.has("size"));
    auto size = entity.get!double("size", entity.get!float("size")); // TODO: should only be double

    return new GraphicSource(source, position, angle, size, data);
  }

  void updateValues()
  {
    blobs.byValue.each!(blob => blob.reset());
    components.each!(component => blobs[component.sourceName].addData(component.transformedData));
    foreach (name, blob; blobs)
    {
      if (name == "textoutline")
        blob.renderTextOutline(shaders, camera.transform);
      else
        blob.render(shaders["coloredtexture"], name == "polygon", camera.transform);
    }
    //blobs.each!((name, blob) => blob.render(shaders["coloredtexture"], name == "polygon", camera.transform));
    //blobs.each!((name, blob) => blob.renderTextOutline(shaders["textoutline"], camera.transform));
    renderer.toScreen();
  }

  void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      components[index].position = entity.get!vec3("position");
      components[index].angle = entity.get!double("angle", entity.get!float("angle"));
      components[index].size = entity.get!double("size", entity.get!float("size"));

      // TODO: should it be possible to change vertices, colors or texCoords for all kinds of components?
      if (components[index].sourceName == "text")
        components[index].data = textRenderer.getGraphicsData(entity.get!string("text"), entity.get!vec4("color"));
    }
  }

  void updateEntities()
  {
    // TODO: set aabb properly using position, angle and vertices
    foreach (index, entity; entityForIndex)
      entity["aabb"] = [components[index].aabb.min, components[index].aabb.max];
  }

  Shader[string] shaders;
  Texture2D[string] textures;
  GraphicsBlob[string] blobs;

  Renderer renderer;
  TextRenderer textRenderer;
  Camera camera;
}
