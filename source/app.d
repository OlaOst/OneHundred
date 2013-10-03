import std.exception;
import std.conv;
import std.stdio;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;

import glamour.shader;
import glamour.vao;
import glamour.vbo;


bool keepRunning = true;

void main()
{
  auto window = getWindow();
  
  static immutable string shaderSource = `
    #version 120
    
    vertex:
      attribute vec2 position;
      void main(void)
      {
        gl_Position = vec4(position, 0, 1);
      }
    
    fragment:
      void main(void)
      {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
      }
  `;
  
  auto vertices = [-0.3, -0.3, 
                    0.3, -0.3, 
                   -0.3,  0.3, 
                    0.3,  0.3];
  auto indices = [0, 1, 2, 3];
  
  auto vao = new VAO();
  vao.bind();
  
  auto vbo = new Buffer(vertices);
  auto ibo = new ElementBuffer(indices);
  
  auto program = new Shader("test", shaderSource);
  program.bind();
  auto position = program.get_attrib_location("position");
  
  scope (exit)
  {
    program.remove();
    ibo.remove();
    vbo.remove();
    vao.remove();
  }
  
  while (keepRunning)
  {
    handleEvents();
    
    vbo.bind();
    glEnableVertexAttribArray(position);
    
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, 0, null);
    
    ibo.bind();
    
    glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, null);
    
    glDisableVertexAttribArray(position);
    
    swapWindow(window);
  }
}


void swapWindow(SDL_Window* window)
{
  SDL_GL_SwapWindow(window);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}


void handleEvents()
{
  SDL_Event event;

  while (SDL_PollEvent(&event))
  {
    switch (event.type)
    {
      case SDL_QUIT:
        keepRunning = false;
        break;
        
      case SDL_KEYUP:
        switch (event.key.keysym.sym)
        {
          case SDLK_ESCAPE:
            keepRunning = false;
            break;
          
          default:
            break;
        }
        break;
        
      default:
        break;
    }
  }
}


SDL_Window* getWindow()
{
  DerelictSDL2.load();
  DerelictGL3.load();
  
  enforce(SDL_Init(SDL_INIT_VIDEO) == 0, "Failed to initialize SDL: " ~ SDL_GetError().to!string);
  
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
  
  int screenWidth = 800;
  int screenHeight = 600;
  
  auto window = SDL_CreateWindow("greenfield", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, screenWidth, screenHeight, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
  enforce(window !is null, "Error creating window");
  
  auto context = SDL_GL_CreateContext(window);
  enforce(context !is null, "Error creating OpenGL context");
  
  SDL_GL_SetSwapInterval(1);
  
  // setup gl viewport and etc
  glClearColor(0.0, 0.0, 0.5, 1.0);
  
  glViewport(0, 0, screenWidth, screenHeight);
  
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  DerelictGL3.reload();
  
  return window;
}
