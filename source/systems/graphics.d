module systems.graphics;

import std.algorithm;
import std.range;

import gl3n.linalg;
import glamour.shader;
import glamour.texture;

import camera;
import components.graphicsource;
import entity;
import renderer.baseshapes;
import renderer.graphicsblob;
import renderer.renderer;
import textrenderer.textrenderer;
import textrenderer.transform;
import system;


class Graphics : System!GraphicSource
{
  this(Renderer renderer, TextRenderer textRenderer, Camera camera, Texture2D[string] textures)
  {
    shader = new Shader("shaders/coloredtexture.shader");
    
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
  
  GraphicSource makeComponent(Entity entity)
  {
    auto source = entity.get!string("graphicsource");
    
    if (source !in textures)
    {
      // these sources should have been preloaded in the textures from the constructor
      assert(source != "polygon");
      assert(source != "text");
      textures[source] = Texture2D.from_image(source);
    }
    if (source !in blobs)
      blobs[source] = new GraphicsBlob(textures[source]);
    
    auto position = entity.get!vec3("position");
    auto angle = entity.get!double("angle", entity.get!float("angle"));
    assert(entity.has("size"));
    auto size = entity.get!double("size", entity.get!float("size")); // TODO: should only be double
    
    vec3[] vertices;
    vec4[] colors;
    vec2[] texCoords;
    if (source == "polygon")
    {
      vertices = entity.get!(vec3[])("polygon.vertices");
      texCoords = vec2(0.0, 0.0).repeat(vertices.length).array;
      if (entity.has("polygon.colors"))
        colors = entity.get!(vec4[])("polygon.colors");
      else
        colors = entity.get!vec4("color").repeat(vertices.length).array;
    }
    else if (source == "text")
    {
      vertices = textRenderer.getVerticesForText(entity.get!string("text")).dup;
      texCoords = textRenderer.getTexCoordsForText(entity.get!string("text")).dup;
      colors = entity.get!vec4("color").repeat(vertices.length).array;
    }
    else
    {
      vertices = baseSquare.dup.map!(vertex => vertex * mat3.zrotation(PI/2)).array;
      texCoords = baseTexCoordsSquare.dup;
      colors = vec4(0.0).repeat(vertices.length).array;
    }
    
    assert(position.isFinite);
    assert(!angle.isNaN);
    assert(size > 0.0, size.to!string);
    
    return new GraphicSource(source, position, angle, size, vertices, texCoords, colors);
  }
  
  void updateValues()
  {
    // reset blobs
    blobs.byValue.each!(blob => blob.reset());
    
    // add to blobs
    foreach (component; components)
    {
      // transform component
      assert(component.sourceName in blobs);
      
      blobs[component.sourceName].vertices ~= component.transformedVertices;
      blobs[component.sourceName].colors ~= component.colors;
      blobs[component.sourceName].texCoords ~= component.texCoords;
    }
    
    blobs.each!((name, blob) => blob.render(shader, name == "polygon", camera.transform));
    
    renderer.toScreen();
  }
  
  void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      components[index].position = entity.get!vec3("position");
      components[index].angle = entity.get!double("angle", entity.get!float("angle"));
      components[index].size = entity.get!double("size", entity.get!float("size"));
      
      // TODO: should it be possible to change vertices, colors or texCoords?
    }
  }
  
  void updateEntities()
  {
    // TODO: set aabb properly using position, angle and vertices
    foreach (index, entity; entityForIndex)
      entity["aabb"] = [components[index].aabb.min, components[index].aabb.max];
  }
  
  Shader shader;
  Texture2D[string] textures;
  GraphicsBlob[string] blobs;
  
  Renderer renderer;
  TextRenderer textRenderer;
  Camera camera;
}
