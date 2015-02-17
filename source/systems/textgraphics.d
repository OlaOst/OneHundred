module systems.textgraphics;

import std.datetime;
import std.range;

import glamour.texture;
import gl3n.aabb;
import gl3n.linalg;

import camera;
import components.drawables.text;
import converters;
import entity;
import system;
import textrenderer.textrenderer;
import textrenderer.transform;


class TextGraphics : System!Text
{
  this(int xres, int yres, Camera camera)
  {
    this.xres = xres; this.yres = yres;
    this.camera = camera;
    textRenderer = new TextRenderer();
    textureSet["text"] = textRenderer.atlas;
  }
  
  ~this()
  {
    foreach (name, texture; textureSet)
      texture.remove();
  }

  override bool canAddEntity(Entity entity)
  {
    return entity.has("position") && entity.has("text") && entity.has("size") && entity.has("color");
  }

  override Text makeComponent(Entity entity)
  {
    Text component = new Text(entity.get!double("size"),
                              entity.get!string("text"),
                              entity.get!vec4("color"));
    component.position = entity.get!vec2("position");
    component.angle = entity.get!double("angle");
    
    //auto textVertices = textRenderer.getVerticesForText(component, 1.0, (vec2 vertex, /*Text*/ component, /*Camera*/ camera) => vertex);
    auto textVertices = textRenderer.getVerticesForText(component, camera);
    
    component.aabb = AABB.from_points(textVertices.map!(vertex => vec3(vertex, 0.0)).array);
    entity["aabb"] = [component.aabb.min.xy, 
                      component.aabb.max.xy];
                      
    return component;
  }

  override void updateValues() //@nogc
  {
    vertices = texCoords = null;
    colors = null;

    //StopWatch timer;
    //timer.start;
    
    static vec2[65536] texCoordBuffer;
    static vec2[65536] verticesBuffer;
    static vec4[65536] colorBuffer;
    
    size_t texCoordIndex = 0;
    size_t verticesIndex = 0;
    size_t colorIndex = 0;
    
    foreach (component; components)
    {
      /*static auto transform = function (vec2 vertex, Text component, Camera camera) => ((vec3(vertex, 0.0)*mat3.zrotation(-component.angle)).xy +
                                                                                        component.position - camera.position) *
                                                                                        camera.zoom;*/
      //texCoords["text"] ~= textRenderer.getTexCoordsForText(component);
      //vertices["text"] ~= textRenderer.getVerticesForText(component, camera.zoom, transform);
      //component.aabb = AABB.from_points(textRenderer.getVerticesForText(component, 1.0, 
      //                  (vec2 vertex) => vertex).map!(vertex => vec3(vertex, 0.0)).array);
      //colors["text"] ~= component.color.repeat.take
      //                    (textRenderer.getTexCoordsForText(component).length).array;
      
      auto texCoords = textRenderer.getTexCoordsForText(component);
      texCoordBuffer[texCoordIndex .. texCoordIndex + texCoords.length] = texCoords;
      texCoordIndex += texCoords.length;
       
      //auto vertices = textRenderer.getVerticesForText(component, camera.zoom, transform);
      auto vertices = textRenderer.getVerticesForText(component, camera);
      verticesBuffer[verticesIndex .. verticesIndex + vertices.length] = vertices;
      verticesIndex += vertices.length;
      
      //auto colors = component.color.repeat.take(textRenderer.getTexCoordsForText(component).length).array;
      auto colors = textRenderer.getTexCoordsForText(component).length;
      colorBuffer[colorIndex .. colorIndex + colors] = component.color;
      colorIndex += colors;
      
      component.aabb = AABB.from_points(textRenderer.getVerticesForText(component, camera).map!(vertex => vec3(vertex, 0.0)).array);
    }
    
    texCoords["text"] = texCoordBuffer[0 .. texCoordIndex];
    vertices["text"] = verticesBuffer[0 .. verticesIndex];
    colors["text"] = colorBuffer[0 .. colorIndex];
  }

  override void updateEntities() 
  {
    foreach (index, entity; entityForIndex)
    {
      entity["aabb"] = [components[index].aabb.min.xy * (1.0/camera.zoom) - components[index].position,
                        components[index].aabb.max.xy * (1.0/camera.zoom) - components[index].position];
    }
  }

  override void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      components[index].position = entity.get!vec2("position");
      components[index].angle = entity.get!double("angle");
      if (components[index].text !is null)
        components[index].text = entity.get!string("text");
    }
  }

  immutable int xres, yres;
  TextRenderer textRenderer;
  Camera camera;
  vec2[][string] vertices, texCoords;
  vec4[][string] colors;
  Texture2D[string] textureSet;
}
