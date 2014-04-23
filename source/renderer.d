module renderer;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import gl3n.linalg; 
import glamour.shader;
import glamour.texture;
import glamour.vao;
import glamour.vbo;

import window;


class Renderer
{
  this(int xres, int yres)
  {
    window = getWindow(xres, yres);

    vao = new VAO();
    vao.bind();
    
    shaderSet["default"] = new Shader("shader/default.shader");
    shaderSet["texture"] = new Shader("shader/texture.shader");
    shaderSet["debugCircle"] = new Shader("shader/debugCircle.shader");
  }
  
  public void close()
  {
    foreach (shader; shaderSet.values)
      shader.remove();
    foreach (vbo; vboSet.values)
      vbo.remove();
    if (vao !is null) 
      vao.remove();
  }
  
  public void draw(vec2[][string] vertices, vec4[][string] colors, vec2[][string] texCoords, Texture2D[string] textureSet)
  {
    glClearColor(0.0, 0.0, 0.33, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      
    if ("polygon" in vertices && "polygon" in colors)
    {
      drawPolygons(vertices["polygon"], colors["polygon"]);
      
      //debug drawDebugCircles(vertices["coveringSquare"], vertices["coveringTexCoords"]);
    }
    
    if ("text" in vertices && "text" in texCoords)
    {
      textureSet["fontAtlas"].bind();
      drawTexture(vertices["text"], texCoords["text"]);
    }
    
    if ("sprite" in vertices && "sprite" in texCoords)
    {
      textureSet["testship"].bind();
      drawTexture(vertices["sprite"], texCoords["sprite"]);
    }
    
    SDL_GL_SwapWindow(window);
  }
  
  void drawPolygons(vec2[] vertices, vec4[] colors)
  in
  {
    assert(vertices.length == colors.length);
  }
  body
  {
    vboSet["vertices"] = new Buffer(vertices);
    vboSet["colors"] = new Buffer(colors);
    
    shaderSet["default"].bind();
    vboSet["vertices"].bind(shaderSet["default"], "position", GL_FLOAT, 2, 0, 0);
    vboSet["colors"].bind(shaderSet["default"], "color", GL_FLOAT, 4, 0, 0);
    
    glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices.length));
    
    vboSet["vertices"].remove();
    vboSet["colors"].remove();
  }
  
  void drawTexture(vec2[] vertices, vec2[] texCoords)
  in
  {
    assert(vertices.length == texCoords.length);
  }
  body
  {
    vboSet["vertices"] = new Buffer(vertices);
    vboSet["texture"] = new Buffer(texCoords);
    
    shaderSet["texture"].bind();
    vboSet["vertices"].bind(shaderSet["texture"], "position", GL_FLOAT, 2, 0, 0);
    vboSet["texture"].bind(shaderSet["texture"], "texCoords", GL_FLOAT, 2, 0, 0);
    
    glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices.length));
    
    vboSet["vertices"].remove();
    vboSet["texture"].remove();
  }
  
  void drawDebugCircles(vec2[] vertices, vec2[] texCoords)
  {
    vboSet["vertices"] = new Buffer(vertices);
    vboSet["texture"] = new Buffer(texCoords);
    
    shaderSet["debugCircle"].bind();
    vboSet["vertices"].bind(shaderSet["debugCircle"], "position", GL_FLOAT, 2, 0, 0);
    vboSet["texture"].bind(shaderSet["debugCircle"], "texCoords", GL_FLOAT, 2, 0, 0);
    
    glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices.length));
    
    vboSet["vertices"].remove();
    vboSet["texture"].remove();
  }
  
private:
  SDL_Window *window;
  VAO vao;
  Buffer[string] vboSet;
  Shader[string] shaderSet;
  Texture2D[string] textureSet;
}
