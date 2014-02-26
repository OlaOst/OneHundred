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
import component.drawables.polygon;
import component.drawables.text;
import component.position;
import component.velocity;
import textrenderer;


final class Renderer : EntityProcessingSystem
{
  mixin TypeDecl;
  
  this()
  {
    super(Aspect.getAspectForAll!(Drawable));
    
    textRenderer = new TextRenderer();
    
    immutable string defaultShaderSource = readText("shader/default.shader");
    immutable string textureShaderSource = readText("shader/texture.shader");
  
    vao = new VAO();
    vao.bind();
    
    defaultShader = new Shader("defaultshader", defaultShaderSource);
    textureShader = new Shader("textureshader", textureShaderSource);
  }
  
  public void close()
  {
    if (defaultShader !is null) defaultShader.remove();
    if (textureShader !is null) textureShader.remove();
    if (verticesVbo !is null) verticesVbo.remove();
    if (colorsVbo !is null) colorsVbo.remove();
    if (vao !is null) vao.remove();
    if (textRenderer !is null) textRenderer.close();
  }
  
  public void draw()
  {
    // create new vbo from new vertices built up in process
    // TODO: make vbo with max amount of vertices drawable, to prevent reinitalizing every frame. 
    //       but would be a premature optimization without profiling
  
    glClearColor(0.0, 0.0, 0.33, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    verticesVbo = new Buffer(vertices);
    colorsVbo = new Buffer(colors);
    
    auto texs = vertices.map!(vertex => (vertex - vertices.reduce!("a+b") * (1.0/vertices.length)).normalized + vec2(0.5, 0.5)).array; //[[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0]];
    textureVbo = new Buffer(texs);
    
    //defaultShader.bind();
    textureShader.bind();
    
    //verticesVbo.bind(defaultShader, "position", GL_FLOAT, 2, 0, 0);
    //colorsVbo.bind(defaultShader, "color", GL_FLOAT, 3, 0, 0);
    verticesVbo.bind(textureShader, "position", GL_FLOAT, 2, 0, 0);
    textureVbo.bind(textureShader, "texCoords", GL_FLOAT, 2, 0, 0);
    
    glDrawArrays(GL_TRIANGLES, 0, cast(int)vertices.length);
    
    // clear vertices and vbo for the next frame
    vertices.length = colors.length = 0;
    verticesVbo.remove();
    colorsVbo.remove();
    
    drawText();
  }
  
  public void drawText()
  {
    textureShader.bind();
    
    auto verts = [[-1.0, -1.0], [-1.0, 1.0], [1.0, 1.0], [1.0, -1.0]];
    auto texs = [[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0]];
    
    verticesVbo = new Buffer(verts[0..3] ~ verts[0..1] ~ verts[2..4]);
    textureVbo = new Buffer(texs[0..3] ~ texs[0..1] ~ texs[2..4]);
    
    verticesVbo.bind(textureShader, "position", GL_FLOAT, 2, 0, 0);
    textureVbo.bind(textureShader, "texCoords", GL_FLOAT, 2, 0, 0);
    
    textRenderer.bind();
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    verticesVbo.remove();
    textureVbo.remove();
  }
  
  override void process(Entity entity)
  {
    auto position = entity.getComponent!Position;
    auto polygon = entity.getComponent!Polygon;
    auto text = entity.getComponent!Text;    
    
    assert(position !is null);
    
    if (polygon !is null)
    {
      vertices ~= polygon.vertices.map!(vertex => ((vec3(vertex, 0.0) * 
                                                    mat3.zrotation(position.angle)).xy + 
                                                    position - cameraPosition) 
                                                    * zoom).array();
                                                    
      colors ~= polygon.colors;
    }
    else if (text !is null)
    {
      //vertices ~= 
    }
  }

  
public:
  vec2 cameraPosition = vec2(0.0, 0.0);
  float zoom = 0.3;
  
private:
  vec2[] vertices;
  vec3[] colors;
  
  VAO vao;
  Buffer verticesVbo;
  Buffer colorsVbo;
  Buffer textureVbo;
  Shader defaultShader;
  Shader textureShader;
  
  TextRenderer textRenderer;
}
