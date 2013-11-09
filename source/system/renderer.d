module system.renderer;

import std.algorithm;
import std.array;
import std.file;

import artemisd.all;
import derelict.opengl3.gl3;
import gl3n.linalg;
import glamour.shader;
import glamour.vao;
import glamour.vbo;

import component.drawable;
import component.position;


final class Renderer : EntityProcessingSystem
{
  mixin TypeDecl;
  
  this()
  {
    super(Aspect.getAspectForAll!(Drawable));
    
    immutable string shaderSource = readText("shader/default.shader");
  
    vao = new VAO();
    vao.bind();
    
    shader = new Shader("shader", shaderSource);
    shader.bind();
    position = shader.get_attrib_location("position");
    
    import std.stdio;
  }
  
  public void close()
  {
    if (shader !is null) shader.remove();
    if (vbo !is null) vbo.remove();
    if (vao !is null) vao.remove();
  }
  
  public void draw()
  {
    // create new vbo from new vertices built up in process
    // TODO: make vbo with max amount of vertices drawable, to prevent reinitalizing every frame. 
    //       but would be a premature optimization without profiling
    vbo = new Buffer(vertices);
  
    glClearColor(0.0, 0.0, 0.33, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    shader.bind();
    
    vbo.bind();
    glEnableVertexAttribArray(position);
    
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, 0, null);
    
    glDrawArrays(GL_TRIANGLES, 0, vertices.length);
    
    glDisableVertexAttribArray(position);
    
    // clear vertices and vbo for the next frame
    vertices.length = 0;
    vbo.remove();
  }
  
  override void process(Entity entity)
  {
    auto drawable = entity.getComponent!Drawable;
    auto position = entity.getComponent!Position;
    
    assert(drawable !is null);
    assert(position !is null);
    
    vertices ~= drawable.vertices.map!(vertex => vertex + position.position).array();
  }

  
private:
  vec2[] vertices;
  
  VAO vao;
  Buffer vbo;
  Shader shader;
  GLint position = 0;
}
