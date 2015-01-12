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
    return "position" in entity.values && Text.canMakeComponent(entity.values);
  }

  override Text makeComponent(Entity entity)
  {
    Text component = new Text(entity.get!double("size"),
                              entity.get!string("text"),
                              entity.get!vec4("color"));
    component.position = entity.get!vec2("position");
    component.angle = entity.get!double("angle");
    auto textVertices = textRenderer.getVerticesForText(component, 1.0, (vec2 vertex) => vertex);
    component.aabb = AABB.from_points(textVertices.map!(vertex => vec3(vertex, 0.0)).array);
    return component;
  }

  override void updateValues()
  {
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
  }

  override void updateEntities() 
  {
    foreach (index, entity; entityForIndex)
    {
      entity.values["aabb"] = [components[index].aabb.min.xy, 
                               components[index].aabb.max.xy].to!string;
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
