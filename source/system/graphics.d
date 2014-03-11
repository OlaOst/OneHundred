module system.graphics;

import std.algorithm;
import std.array;
import std.range;
import std.stdio;
import std.string;

import artemisd.all;
import gl3n.linalg; 

import component.drawable;
import component.drawables.polygon;
import component.drawables.text;
import component.position;
import component.velocity;
import textrenderer.textrenderer;


final class Graphics : EntityProcessingSystem
{
  mixin TypeDecl;
  
  this()
  {
    super(Aspect.getAspectForAll!(Drawable));
    
    textRenderer = new TextRenderer();
  }
  
  void close() 
  {
    if (textRenderer !is null) 
      textRenderer.close();
  }
  
  override void process(Entity entity)
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
  }

  vec2[][string] getVertices() { return vertices; }
  vec4[][string] getColors() { return colors; }
  vec2[][string] getTexCoords() { return texCoords; }
  
  void clear()
  {
    vertices = null;
    colors = null;
    texCoords = null;
  }
  
public:
  vec2 cameraPosition = vec2(0.0, 0.0);
  float zoom = 0.3;
  
private:
  TextRenderer textRenderer;
  vec2[][string] vertices;
  vec4[][string] colors;
  vec2[][string] texCoords;
}
