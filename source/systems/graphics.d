module systems.graphics;

import std.algorithm;
import std.array;
import std.stdio;

import glamour.texture;
import gl3n.linalg; 

import component.collider;
import component.drawables.polygon;
import component.drawables.text;
import entity;
import system;
import textrenderer.textrenderer;
import textrenderer.transform;


struct GraphicsComponent
{
  vec2 position;
  double angle;
}

class Graphics : System!GraphicsComponent
{
  this(int xres, int yres)
  {
    this.xres = xres; this.yres = yres;
    textRenderer = new TextRenderer();
    
    textureSet["text"] = textRenderer.atlas;
  }
  
  void close() { textRenderer.close(); }
  
  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.vectors && (entity.polygon !is null || entity.text !is null || entity.sprite !is null);
  }
  
  override GraphicsComponent makeComponent(Entity entity)
  {
    if (entity.sprite !is null)
      textureSet[entity.sprite.fileName] = entity.sprite.texture;

    return GraphicsComponent(entity.vectors["position"], 
                             "angle" in entity.scalars ? entity.scalars["angle"] : 0.0);
  }
  
  /*private void crap()
  {
    auto trans = (float v) => v;
    //auto tja = entity.polygon.vertices.map!(v => ((vec3(v, 0.0) * mat3.zrotation(components[index].angle)).xy + v + components[index].position - cameraPosition) * zoom);
    //auto verts = [vec2(1,1), vec2(2,2), vec2(3,3)]; //entity.polygon.vertices.dup;
    auto verts = [1.0, 2.0, 3.0];
    auto tja = verts.map!trans;
    writeln("front: ", tja.front);
    
    writeln("trans delegate is ", trans);
    
    tja.popFront();
    import std.range;
    writeln("transformed verts length: ", tja.walkLength);
    writeln("popped, empty is ", tja.empty);
    writeln("popped, front: ", tja.front);
    writeln("tja itself: ", tja);
    writeln("tja array: ", tja.array);
  }*/
  
  override void update()
  {
    vertices = null;
    colors = null;
    texCoords = null;
    
    foreach (int index, Entity entity; entityForIndex)
    {
      auto transform = delegate (vec2 vertex) => ((vec3(vertex, 0.0) * 
                                                 mat3.zrotation(components[index].angle)).xy + 
                                                 components[index].position - cameraPosition) *
                                                 zoom;
      
      if (entity.polygon !is null)
      {
        //vertices["coveringSquare"] ~= component.drawable.baseSquare.map!(vertex => vertex * entity.polygon.vertices.map!(v => v.magnitude).reduce!"a > b ? a : b").map!transform.array();
        
        auto coveringSquareVertices = component.drawable.baseSquare.map!(vertex => vertex * entity.polygon.vertices.map!(v => v.magnitude).reduce!"a > b ? a : b").map!transform;
        
        foreach (coveringSquareVertex; coveringSquareVertices)
          vertices["coveringSquare"] ~= coveringSquareVertex;
        
        vertices["coveringTexCoords"] ~= [vec2(-1.0, -1.0), 
                                          vec2( 1.0, -1.0), 
                                          vec2( 1.0,  1.0), 
                                          vec2( 1.0,  1.0),
                                          vec2(-1.0,  1.0),
                                          vec2(-1.0, -1.0)];
      
        // map with delegate in a variable and then array crashes with release build
        //vertices["polygon"] ~= entity.polygon.vertices.map!transform.array();
        auto transformedVertices = entity.polygon.vertices.map!transform;
        foreach (transformedVertex; transformedVertices)
          vertices["polygon"] ~= transformedVertex;
        
        if (entity.collider !is null && entity.collider.isColliding)
          colors["polygon"] ~= entity.polygon.colors.map!(color => vec4(1.0, color.gba)).array;
        else
          colors["polygon"] ~= entity.polygon.colors;
      }
      else if (entity.text !is null)
      {
        texCoords["text"] ~= textRenderer.getTexCoordsForText(entity.text);
        vertices["text"] ~= textRenderer.getVerticesForText(entity.text, zoom, transform);
      }
      else if (entity.sprite !is null)
      {
        // hacky hack that is a hack - images assume angle 0 = pointing UP, while we assume angle 0 = pointing RIGHT. sinx/cosy vs cosx/siny...
        components[index].angle -= PI/2;
        
        auto transformedVertices = entity.sprite.vertices.map!transform;
        foreach (transformedVertex; transformedVertices)
          vertices[entity.sprite.fileName] ~= transformedVertex;
        
        components[index].angle += PI/2;
        
        texCoords[entity.sprite.fileName] ~= [vec2(0.0, 0.0), 
                                              vec2(1.0, 0.0), 
                                              vec2(1.0, 1.0), 
                                              vec2(1.0, 1.0), 
                                              vec2(0.0, 1.0), 
                                              vec2(0.0, 0.0)];
      }
    }
  }
  
  void updateFromEntities()
  {
    foreach (int index, Entity entity; entityForIndex)
    {
      components[index].position = entity.vectors["position"];
      components[index].angle = "angle" in entity.scalars ? entity.scalars["angle"] : 0.0;
    }
  }
  
  vec2 getWorldPositionFromScreenCoordinates(vec2 screenCoordinates)
  {
    return vec2(screenCoordinates.x / cast(float)xres - 0.5, 
                0.5 - screenCoordinates.y / cast(float)yres) * (1.0 / zoom) * 2.0;
  }
  
public:
  vec2 cameraPosition = vec2(0.0, 0.0);
  float zoom = 0.3;
  vec2[][string] vertices;
  vec2[][string] texCoords;
  vec4[][string] colors;
  Texture2D[string] textureSet;
  
private:
  int xres, yres;
  TextRenderer textRenderer;
}
