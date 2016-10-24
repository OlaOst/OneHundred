module renderer.graphicsblob;

import gl3n.linalg;

import glamour.shader;
import glamour.texture;

import renderer.coloredtexturerenderer;
import renderer.graphicsdata;
import renderer.textoutlinerenderer;


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
    data.colors.length = 0;
    data.texCoords.length = 0;
  }
  
  void addData(GraphicsData data)
  {
    this.data.vertices ~= data.vertices;
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
  
  void renderTextOutline(Shader[string] shaderSet, mat4 cameraTransform)
  {
    assert(data);
    
    texture.bind();
    
    /*
    // uncomment this to see text being rendered triangle by triangle, for debugging purposes
    static int counter = 0;
    counter++;
    
    drawTextOutline(shaderSet, 
                    cameraTransform,
                    data.vertices[0 .. (counter / 10)*3 % data.vertices.length],
                    data.texCoords[0 .. (counter / 10)*3 % data.texCoords.length],
                    data.colors[0 .. (counter / 10)*3 % data.colors.length]);
    */
    drawTextOutline(shaderSet, 
                    cameraTransform,
                    data.vertices,
                    data.texCoords,
                    data.colors);
                       
    texture.unbind();
  }
  
  Texture2D texture;
  GraphicsData data;
}
