module renderer;

import derelict.opengl3.gl3;

import glamour.shader;
import glamour.vao;
import glamour.vbo;


class Renderer
{
  this()
  {
    /*auto vertices = [-0.3, -0.3, 
                      0.3, -0.3, 
                     -0.3,  0.3, 
                      0.3,  0.3];*/
    auto vertices = [-1.0, -1.0,
                      1.0, -1.0,
                      0.0,  1.0];
    //auto indices = [0, 1, 2, 3];
    
    static immutable string shaderSource = `
      #version 330 core
      
      vertex:
        //attribute vec2 position;
        layout(location = 0) in vec2 position;
        void main(void)
        {
          gl_Position = vec4(position, 0, 1);
        }
      
      fragment:
        out vec3 color;
        void main(void)
        {
          //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
          color = vec3(1, 0, 0);
        }
    `;
  
    vao = new VAO();
    vao.bind();
    
    vbo = new Buffer(vertices);
    //ibo = new ElementBuffer(indices);
    
    shader = new Shader("shader", shaderSource);
    shader.bind();
    position = shader.get_attrib_location("position");
    
    import std.stdio;
    writeln("position from shader is " ~ position.to!string);
  }
  
  
  public void close()
  {
    shader.remove();
    //ibo.remove();
    vbo.remove();
    vao.remove();
  }
  
  
  public void draw()
  {
    glClearColor(0.0, 0.0, 0.33, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    shader.bind();
    
    vbo.bind();
    glEnableVertexAttribArray(position);
    
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, 0, null);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    //ibo.bind();
    
    //glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, null);
    
    glDisableVertexAttribArray(position);
  }
  

private:
  VAO vao;
  Buffer vbo;
  ElementBuffer ibo;
  Shader shader;
  GLint position = 0;
}
