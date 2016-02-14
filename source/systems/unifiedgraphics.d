module systems.unifiedgraphics;

import std.algorithm;
import std.array;
import std.datetime;
import std.range;
import std.stdio;

import gl3n.aabb;
import gl3n.linalg;
import glamour.shader;
import glamour.texture;

import camera;
import components.drawable;
import components.graphicsource;
import converters;
import entityhandler;
import entity;
import renderer.coloredtexturerenderer;
import renderer.renderer;
import system;
import textrenderer.textrenderer;
import textrenderer.transform;


class GraphicsBlob
{
  this(Texture2D texture)
  {
    this.texture = texture;
  }
  
  void reset()
  {
    vertices.length = 0;
    colors.length = 0;
    texCoords.length = 0;
  }
  
  void render(Shader shader, bool ignoreTexture, mat4 cameraTransform)
  {
    assert(vertices.length == colors.length, vertices.length.to!string ~ " vertices vs " ~ colors.length.to!string ~ " colors");
    assert(vertices.length == texCoords.length);
    
    texture.bind();
    
    drawColoredTexture(shader, 
                       cameraTransform,
                       vertices, 
                       texCoords, 
                       colors,
                       ignoreTexture);
                       
    texture.unbind();
  }
  
  Texture2D texture;
  vec3[] vertices;
  vec4[] colors;
  vec2[] texCoords;
}

class UnifiedGraphics : System!GraphicSource
{
  this(Renderer renderer, TextRenderer textRenderer, Camera camera, Texture2D[string] textures)
  {
    this.xres = renderer.xres; 
    this.yres = renderer.yres;
    
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
      // these sources should have been preloaded in the constructor
      assert(source != "polygon");
      assert(source != "text");
      
      textures[source] = Texture2D.from_image(source);
    }
    
    if (source !in blobs)
      blobs[source] = new GraphicsBlob(textures[source]);
    
    vec3[] vertices;
    vec4[] colors;
    vec2[] texCoords;
    if (source == "polygon")
    {
      vertices = entity.get!(vec3[])("polygon.vertices");
      if (entity.has("polygon.colors"))
        colors = entity.get!(vec4[])("polygon.colors");
      else
        colors = entity.get!vec4("color").repeat(vertices.length).array;
        
      texCoords = vec2(0.0, 0.0).repeat(vertices.length).array;
    }
    else if (source == "text")
    {
      auto text = entity.get!string("text");
      auto position = entity.get!vec3("position");
      auto angle = entity.get!double("angle");
      auto size = entity.get!double("size");
      auto color = entity.get!vec4("color");
      
      // TODO: every letter will have its vertices normalized but we only use one size which should be different for every letter
      
      vertices = textRenderer.getVerticesForText(text, position, angle, size).dup;
      texCoords = textRenderer.getTexCoordsForText(text).dup;
      colors = color.repeat(vertices.length).array;
    }
    else
    {
      auto size = entity.get!double("size");
    
      vertices = baseSquare.dup.map!(vertex => vertex * mat3.zrotation(PI/2)).array;
      texCoords = baseTexCoordsSquare.dup;
      colors = vec4(0.0).repeat(vertices.length).array;
    }
    
    auto position = entity.get!vec3("position");
    auto angle = entity.get!double("angle");
    assert(entity.has("size"));
    auto size = entity.get!double("size", entity.get!float("size")); // TODO: should only be double
    
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
      auto position = entity.get!vec3("position");
      auto angle = entity.get!double("angle");
      auto size = entity.get!double("size");
      
      //components[index].transform = mat3.zrotation(-angle) + mat3.translation(position);
      components[index].position = position;
      components[index].angle = angle;
      
      if (components[index].size != size)
      {
        components[index].size = size;
        
        //auto vertices = components[index].vertices;
        //auto furthestVertex = vertices.minCount!((a, b) => a.magnitude > b.magnitude)[0];
        //components[index].vertices = vertices.map!(vertex => vertex * (1.0 / furthestVertex.magnitude) * size).array;
      }
      
      // TODO: should it be possible to change vertices, colors or texCoords here?
      //if (entity.has("polygon.vertices"))
        //components[index].vertices = entity.get!(vec3[])("polygon.vertices");
      //if (entity.has("polygon.colors"))
        //components[index].colors = entity.get!(vec4[])("polygon.colors");
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
  
  immutable int xres, yres;
}
