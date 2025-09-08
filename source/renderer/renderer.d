module renderer.renderer;

import std;

import bindbc.opengl;
import bindbc.sdl;
import inmath.linalg;
import glamour.shader;
import glamour.texture;
import glamour.vao;
import glamour.vbo;
import glamour.util;

import renderer.coloredtexturerenderer;
import window;


class Renderer
{
  int xres;
  int yres;
  
  public this(int xres, int yres)
  {
    this.xres = xres;
    this.yres = yres;
    
    window = getWindow(xres, yres);
    sdlRenderer = SDL_CreateRenderer(window, null);

    shaderSet = dirEntries("shaders", "*.shader", SpanMode.breadth).
                map!(dirEntry => tuple(dirEntry.name.chompPrefix("shaders\\")
                                                    .chompPrefix("shaders/")
                                                    .chomp(".shader"),
                                       new Shader(dirEntry.name))).assocArray;
    vao = new VAO();
    vao.bind();
  }

  public void close()
  {
    foreach (shader; shaderSet.values)
      shader.remove();
    if (vao !is null)
      vao.remove();
  }

  public void toScreen()
  {
    SDL_GL_SwapWindow(window);
    
    checkgl!glClearColor(0.0, 0.0, 0.33, 1.0);
    checkgl!glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
  }

  public SDL_Renderer* getSDLRenderer()
  {
    return sdlRenderer;
  }

  private SDL_Window *window;
  private SDL_Renderer* sdlRenderer;
  private VAO vao;
  private Shader[string] shaderSet;
}
