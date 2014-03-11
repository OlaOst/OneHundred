module system.renderer;

import std.algorithm;
import std.array;
import std.file;
import std.range;
import std.stdio;
import std.string;

import artemisd.all;
import derelict.opengl3.gl3;
import gl3n.linalg; 
import glamour.shader;
import glamour.vao;
import glamour.vbo;

import component.drawable;
import component.drawables.polygon;
import component.drawables.text;
import component.position;
import component.velocity;
import textrenderer.textrenderer;


final class Renderer : EntityProcessingSystem
{
  mixin TypeDecl;
  
  this()
  {
    super(Aspect.getAspectForAll!(Drawable));
    
    textRenderer = new TextRenderer();
  
    vao = new VAO();
    vao.bind();
    
    defaultShader = new Shader("shader/default.shader");
    textureShader = new Shader("shader/texture.shader");
  }
  
  public void close()
  {
    if (defaultShader !is null) defaultShader.remove();
    if (textureShader !is null) textureShader.remove();
    if (verticesVbo !is null) verticesVbo.remove();
    if (colorsVbo !is null) colorsVbo.remove();
    if (vao !is null) vao.remove();
    if (textRenderer !is null) textRenderer.close();
  }
  
  public void draw()
  {
    // create new vbo from new vertices built up in process
    // TODO: make vbo with max amount of vertices drawable, to prevent reinitalizing every frame. 
    //       but would be a premature optimization without profiling
  
    glClearColor(0.0, 0.0, 0.33, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    drawText();
    drawPolygons();
  }
  
  void drawPolygons()
  {    
    verticesVbo = new Buffer(vertices["polygon"]);
    colorsVbo = new Buffer(colors["polygon"]);
    
    defaultShader.bind();
    
    verticesVbo.bind(defaultShader, "position", GL_FLOAT, 2, 0, 0);
    colorsVbo.bind(defaultShader, "color", GL_FLOAT, 4, 0, 0);
    
    glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices["polygon"].length));
        
    // clear vertices and vbo for the next frame
    vertices["polygon"].length = 0;
    colors["polygon"].length = 0;
    
    verticesVbo.remove();
    colorsVbo.remove();
  }
  
  public void drawText()
  in
  {
    assert(vertices["text"].length == texCoords["text"].length);
  }
  body
  {
    if ("text" !in vertices)
      return;
      
    verticesVbo = new Buffer(vertices["text"]);
    textureVbo = new Buffer(texCoords["text"]);
    
    textureShader.bind();
   
    verticesVbo.bind(textureShader, "position", GL_FLOAT, 2, 0, 0);
    textureVbo.bind(textureShader, "texCoords", GL_FLOAT, 2, 0, 0);
    textRenderer.bind();
    
    glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices["text"].length));
    
    vertices["text"].length = 0;
    texCoords["text"].length = 0;
    
    verticesVbo.remove();
    textureVbo.remove();
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
        
          //auto verts = baseSquare.dup;
      
          texCoords["text"] ~= textRenderer.getTexCoordsForLetter(letter);
          vertices["text"] ~= text.vertices.map!(vertex => ((vec3(vertex, 0.0) *
                                                  mat3.zrotation(position.angle)).xy + 
                                                  position - cameraPosition + glyph.offset*text.size + cursor) * 
                                                  zoom).array();
          
          cursor += glyph.advance * text.size * 2.0;
        }
        cursor = vec2(0.0, cursor.y - text.size * 2.0);
      }
    }
  }

  
public:
  vec2 cameraPosition = vec2(0.0, 0.0);
  float zoom = 0.3;
  
private:
  vec2[][string] vertices;
  vec4[][string] colors;
  vec2[][string] texCoords;
  
  VAO vao;
  Buffer verticesVbo;
  Buffer colorsVbo;
  Buffer textureVbo;
  Shader defaultShader;
  Shader textureShader;
  
  TextRenderer textRenderer;
}
