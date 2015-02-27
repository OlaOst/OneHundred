module renderer;

import std.algorithm;
import std.array;
import std.file;
import std.range;
import std.string;

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
  public this(int xres, int yres)
  {
    window = getWindow(xres, yres);
    vao = new VAO();
    vao.bind();
    shaderSet = dirEntries("shaders", "*.shader", SpanMode.breadth).
                map!(dirEntry => tuple(dirEntry.name.chompPrefix("shaders\\")
                                                    .chompPrefix("shaders/")
                                                    .chomp(".shader"),
                                       new Shader(dirEntry.name))).assocArray;
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

  public void render(vec3[][string] vertices, vec4[][string] colors,
                     vec2[][string] texCoords, Texture2D[string] textureSet)
  {
    if ("polygon" in vertices && "polygon" in colors)
      drawPolygons(vertices["polygon"], colors["polygon"]);
    foreach (name; texCoords.byKey)
    {
      textureSet[name].bind();
      auto colorsForTexture = colors.get(name, vec4(1.0).repeat(vertices[name].length).array);
      drawColoredTexture(vertices[name], texCoords[name], colorsForTexture);
    }
    toScreen();
  }

  public void toScreen()
  {
    SDL_GL_SwapWindow(window);
    glClearColor(0.0, 0.0, 0.33, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  }

  public void drawPolygons(vec3[] vertices, vec4[] colors)
  {
    assert(vertices.length == colors.length);
    vboSet["vertices"] = new Buffer(vertices);
    vboSet["colors"] = new Buffer(colors);
    shaderSet["default"].bind();
    vboSet["vertices"].bind(shaderSet["default"], "position", GL_FLOAT, 3, 0, 0);
    vboSet["colors"].bind(shaderSet["default"], "color", GL_FLOAT, 4, 0, 0);
    glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices.length));
    vboSet["vertices"].remove();
    vboSet["colors"].remove();
  }

  public void drawColoredTexture(vec3[] vertices, vec2[] texCoords, vec4[] colors)
  {
    assert(vertices.length == texCoords.length);
    assert(vertices.length == colors.length);
    vboSet["vertices"] = new Buffer(vertices);
    vboSet["texture"] = new Buffer(texCoords);
    vboSet["colors"] = new Buffer(colors);
    shaderSet["coloredtexture"].bind();
    vboSet["vertices"].bind(shaderSet["coloredtexture"], "position", GL_FLOAT, 3, 0, 0);
    vboSet["texture"].bind(shaderSet["coloredtexture"], "texCoords", GL_FLOAT, 2, 0, 0);
    vboSet["colors"].bind(shaderSet["coloredtexture"], "color", GL_FLOAT, 4, 0, 0);
    glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices.length));
    vboSet["vertices"].remove();
    vboSet["texture"].remove();
    vboSet["colors"].remove();
  }
  
  private SDL_Window *window;
  private VAO vao;
  private Buffer[string] vboSet;
  private Shader[string] shaderSet;
}
