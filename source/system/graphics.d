module system.graphics;

import std.algorithm;
import std.array;
import std.range;
import std.stdio;
import std.string;

import gl3n.linalg; 

import component.drawable;
import component.drawables.polygon;
import component.drawables.text;
import entity;
import system.system;
import textrenderer.textrenderer;


class Graphics : System
{ 
  vec2[] positions;
  double[] angles;
  
  this(int xres, int yres)
  {
    this.xres = xres;
    this.yres = yres;
    
    textRenderer = new TextRenderer();
  }
  
  void close() 
  {
    if (textRenderer !is null) 
      textRenderer.close();
  }
  
  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.vectors && (entity.polygon !is null || entity.text !is null);
  }
  
  override void addEntity(Entity entity)
  {
    if (canAddEntity(entity))
    {
      indexForEntity[entity] = positions.length;
      entityForIndex[positions.length] = entity;
      
      positions ~= entity.vectors["position"];
      if ("angle" in entity.scalars)
        angles ~= entity.scalars["angle"];
      else
        angles ~= 0.0;
    }
  }
  
  override void update()
  {
    foreach (int index, Entity entity; entityForIndex)
    {
      if (entity.polygon !is null)
      {
        vertices["polygon"] ~= entity.polygon.vertices.map!(vertex => ((vec3(vertex, 0.0) * 
                                                                      mat3.zrotation(angles[index])).xy + 
                                                                      positions[index] - cameraPosition) *
                                                                      zoom).array();
        //colors["polygon"] ~= entity.polygon.colors;
        
        import component.collider;
        if (entity.collider !is null && entity.collider.isColliding)                                              
          colors["polygon"] ~= entity.polygon.colors.map!(color => vec4(1.0, color.g, color.b, color.a)).array;
        else
          colors["polygon"] ~= entity.polygon.colors;
      }
      else if (entity.text !is null)
      {
        auto cursor = vec2(0.0, 0.0);
        
        auto lines = entity.text.text.split("\n");
        foreach (line; lines)
        {
          foreach (letter; line)
          {
            auto glyph = textRenderer.getGlyphForLetter(letter);
        
            texCoords["text"] ~= textRenderer.getTexCoordsForLetter(letter);
            vertices["text"] ~= entity.text.vertices.map!(vertex => ((vec3(vertex, 0.0) *
                                                                    mat3.zrotation(angles[index])).xy + 
                                                                    positions[index] - cameraPosition + 
                                                                    glyph.offset * entity.text.size + cursor) * 
                                                                    zoom).array();
            
            cursor += glyph.advance * entity.text.size * 2.0;
          }
          cursor = vec2(0.0, cursor.y - entity.text.size * 2.0);
        }
      }
    }
  }
  
  void updateFromEntities()
  {
    foreach (int index, Entity entity; entityForIndex)
    {
      //entity.vectors["position"] = currentStates[index].position;
      //entity.scalars["angle"] = currenStates[index].angle;
      positions[index] = entity.vectors["position"];
      
      if ("angle" in entity.scalars)
        angles[index] = entity.scalars["angle"];
      else
        angles[index] = 0.0;
    }
  }
  
  /+override void process(Entity entity)
  {
    auto position = entity.getComponent!Position;
    auto polygon = entity.getComponent!Polygon;
    auto text = entity.getComponent!Text;    
    
    assert(position !is null);
    
    if (polygon !is null)
    {
      vertices["polygon"] ~= polygon.vertices.map!(vertex => ((vec3(vertex, 0.0) * 
                                                    mat3.zrotation(position.angle)).xy + 
                                                    position - cameraPosition) *
                                                    zoom).array();

      import component.collider;      
      if (entity.getComponent!Collider !is null && entity.getComponent!Collider.isColliding)                                              
        colors["polygon"] ~= polygon.colors.map!(color => vec4(1.0, color.g, color.b, color.a)).array;
      else
        colors["polygon"] ~= polygon.colors;
    }
    else if (text !is null)
    {
      auto cursor = vec2(0.0, 0.0);
      
      auto lines = text.text.split("\n");
      foreach (line; lines)
      {
        foreach (letter; line)
        {
          auto glyph = textRenderer.getGlyphForLetter(letter);
      
          texCoords["text"] ~= textRenderer.getTexCoordsForLetter(letter);
          vertices["text"] ~= text.vertices.map!(vertex => ((vec3(vertex, 0.0) *
                                                  mat3.zrotation(position.angle)).xy + 
                                                  position - cameraPosition + 
                                                  glyph.offset*text.size + cursor) * 
                                                  zoom).array();
          
          cursor += glyph.advance * text.size * 2.0;
        }
        cursor = vec2(0.0, cursor.y - text.size * 2.0);
      }
    }
  }+/

  vec2[][string] getVertices() { return vertices; }
  vec4[][string] getColors() { return colors; }
  vec2[][string] getTexCoords() { return texCoords; }
  
  void clear()
  {
    vertices = null;
    colors = null;
    texCoords = null;
  }
  
  vec2 getWorldPositionFromScreenCoordinates(vec2 screenCoordinates)
  {
    return vec2(screenCoordinates.x / cast(float)xres - 0.5, 0.5 - screenCoordinates.y / cast(float)yres) * 
           (1.0 / zoom) * 2.0;
  }
  
public:
  vec2 cameraPosition = vec2(0.0, 0.0);
  float zoom = 0.3;
  
private:
  int xres;
  int yres;
  
  TextRenderer textRenderer;
  vec2[][string] vertices;
  vec4[][string] colors;
  vec2[][string] texCoords;
}
