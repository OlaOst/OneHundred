module renderer.graphicsblob;

import inmath.linalg;

import glamour.shader;
import glamour.texture;

import renderer.coloredtexturerenderer;
import renderer.graphicsdata;


class GraphicsBlob
{
  this(Texture2D texture)
  {
    this.texture = texture;
    data = new GraphicsData();
  }
  
  this(Texture2D texture, GraphicsData data)
  {
    this.texture = texture;
    this.data = data;
  }
  
  void reset()
  {
    data.vertices.length = 0;
    data.controlVertices.length = 0;
    data.colors.length = 0;
    data.texCoords.length = 0;
  }
  
  void addData(GraphicsData data)
  {
    this.data.vertices ~= data.vertices;
    this.data.controlVertices ~= data.controlVertices;
    this.data.texCoords ~= data.texCoords;
    this.data.colors ~= data.colors;
  }
  
  void render(Shader shader, bool ignoreTexture, mat4 cameraTransform)
  {
    assert(data);
    
    texture.bind();
    
    drawColoredTexture(shader, 
                       cameraTransform,
                       data.vertices, 
                       data.texCoords, 
                       data.colors,
                       ignoreTexture);
                       
    texture.unbind();
  }
  
  Texture2D texture;
  GraphicsData data;
}
