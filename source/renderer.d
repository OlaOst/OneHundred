module renderer;

import std.algorithm;
import std.array;
import std.file;
import std.range;
import std.stdio;
import std.string;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import gl3n.linalg; 
import glamour.shader;
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
    
    //auto ctx = CGLGetCurrentContext();
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
  
  public void draw(vec2[][string] vertices, vec4[][string] colors, vec2[][string] texCoords)
  {
    glClearColor(0.0, 0.0, 0.33, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    drawText(vertices["text"], texCoords["text"]);
    drawPolygons(vertices["polygon"], colors["polygon"]);
    
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
  
  public void drawText(vec2[] vertices, vec2[] texCoords)
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
  
private:
  SDL_Window *window;
  VAO vao;
  Buffer[string] vboSet;
  Shader[string] shaderSet;
}
