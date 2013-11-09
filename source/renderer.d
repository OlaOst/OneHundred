module renderer;

import derelict.opengl3.gl3;

import glamour.shader;
import glamour.vao;
import glamour.vbo;


class Renderer
{
  this()
  {
    /*float[] vertices = [-0.3, -0.3, 
                      0.3, -0.3, 
                     -0.3,  0.3, 
                      0.3,  0.3];*/
    float[] vertices = [-1.0, -1.0,
                         1.0, -1.0,
                         0.0,  1.0];
    ushort[] indices = [0, 1, 2, 3];
    
    static immutable string shaderSource = `
      #version 330 core
      
      vertex:
        layout(location = 0) in vec2 position;
        void main(void)
        {
          gl_Position = vec4(position, 0, 1);
        }
      
      fragment:
        out vec3 color;
        void main(void)
        {
          color = vec3(1, 0, 0);
        }
    `;
  
    vao = new VAO();
    vao.bind();
    
    vbo = new Buffer(vertices);
    ibo = new ElementBuffer(indices);
    
    shader = new Shader("shader", shaderSource);
    shader.bind();
    position = shader.get_attrib_location("position");
    
    import std.stdio;
  }
  
  
  public void close()
  {
    if (shader !is null) shader.remove();
    if (ibo !is null) ibo.remove();
    if (vbo !is null) vbo.remove();
    if (vao !is null) vao.remove();
  }
  
  
  public void draw()
  {
    glClearColor(0.0, 0.0, 0.33, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    shader.bind();
    
    vbo.bind();
    glEnableVertexAttribArray(position);
    
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, 0, null);
    
    //ibo.bind();
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
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
