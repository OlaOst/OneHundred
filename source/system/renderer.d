module system.renderer;

import std.algorithm;
import std.array;
import std.file;
import std.range;

import artemisd.all;
import derelict.opengl3.gl3;
import gl3n.linalg;
import glamour.shader;
import glamour.vao;
import glamour.vbo;

import component.drawable;
import component.position;
import component.velocity;


final class Renderer : EntityProcessingSystem
{
  mixin TypeDecl;
  
  this()
  {
    super(Aspect.getAspectForAll!(Drawable));
    
    immutable string shaderSource = readText("shader/default.shader");
  
    vao = new VAO();
    vao.bind();
    
    shader = new Shader("defaultshader", shaderSource);
    shader.bind();
    
    import std.stdio;
  }
  
  public void close()
  {
    if (shader !is null) shader.remove();
    if (verticesVbo !is null) verticesVbo.remove();
    if (colorsVbo !is null) colorsVbo.remove();
    if (vao !is null) vao.remove();
  }
  
  public void draw()
  {
    // create new vbo from new vertices built up in process
    // TODO: make vbo with max amount of vertices drawable, to prevent reinitalizing every frame. 
    //       but would be a premature optimization without profiling
    verticesVbo = new Buffer(vertices);
    //colorsVbo = new Buffer(colors ~ colors ~ colors);
    colorsVbo = new Buffer(colors);
  
    glClearColor(0.0, 0.0, 0.33, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    shader.bind();
    
    verticesVbo.bind(shader, "position", GL_FLOAT, 2, 0, 0);
    colorsVbo.bind(shader, "color", GL_FLOAT, 3, 0, 0);
    
    glDrawArrays(GL_TRIANGLES, 0, vertices.length);
    
    // clear vertices and vbo for the next frame
    vertices.length = 0;
    colors.length = 0;
    verticesVbo.remove();
    colorsVbo.remove();
  }
  
  override void process(Entity entity)
  {
    auto drawable = entity.getComponent!Drawable;
    auto position = entity.getComponent!Position;
    auto velocity = entity.getComponent!Velocity;
    
    assert(drawable !is null);
    assert(position !is null);
    assert(velocity !is null);
    
    vec3 color = vec3(velocity.magnitude^^2, (velocity.magnitude * 0.5).sqrt, (velocity.magnitude * 0.1).sqrt.sqrt);
    
    vertices ~= drawable.vertices.map!(vertex => (vec3(vertex, 0.0) * mat3.zrotation(position.angle)).xy + position.position).array();
    colors ~= color.repeat(drawable.vertices.length).array();
  }

  
private:
  vec2[] vertices;
  vec3[] colors;
  
  VAO vao;
  Buffer verticesVbo;
  Buffer colorsVbo;
  Shader shader;
}
