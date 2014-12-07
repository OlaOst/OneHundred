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
    return "position" in entity.values && "angle" in entity.values &&
           Text.canMakeComponent(entity.values);
  }

  override Text makeComponent(Entity entity)
  {
    Text component = new Text(entity.values["size"].to!double,
                              entity.values["text"],
                              entity.values["color"].myTo!vec4);

    component.position = vec2(entity.values["position"].to!(float[2]));
    component.angle = entity.values["angle"].to!double;

    auto textVertices = textRenderer.getVerticesForText(component, 1.0, (vec2 vertex) => vertex);
    component.aabb = AABB.from_points(textVertices.map!(vertex => vec3(vertex, 0.0)).array);
    
    return component;
  }

  override void updateValues()
  {
    StopWatch debugTimer;
    debugTimer.start;
    vertices = texCoords = null;
    colors = null;

    foreach (component; components)
    {
      auto transform = (vec2 vertex) => ((vec3(vertex, 0.0)*mat3.zrotation(-component.angle)).xy +
                                         component.position - camera.position) *
                                         camera.zoom;
      
      texCoords["text"] ~= textRenderer.getTexCoordsForText(component);
      vertices["text"] ~= textRenderer.getVerticesForText(component, camera.zoom, transform);
      component.aabb = AABB.from_points(textRenderer.getVerticesForText(component, 1.0, 
                        (vec2 vertex) => vertex).map!(vertex => vec3(vertex, 0.0)).array);
      colors["text"] ~= component.color.repeat.take
                          (textRenderer.getTexCoordsForText(component).length).array;
    }
    debugText = format("textgraphics timings: %s", debugTimer.peek.usecs*0.001);
  }

  override void updateEntities() {}

  override void updateFromEntities()
  {
    foreach (uint index, Entity entity; entityForIndex)
    {
      components[index].position = entity.values["position"].myTo!vec2;
      components[index].angle = entity.values["angle"].to!double;

      if (components[index].text !is null)
        components[index].text = entity.values["text"];
    }
  }

  immutable int xres, yres;
  TextRenderer textRenderer;
  Camera camera;
  vec2[][string] vertices, texCoords;
  vec4[][string] colors;
  Texture2D[string] textureSet;
}
