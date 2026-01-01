module renderer.graphicsblob;

import std;

import inmath.linalg;

import glamour.shader;
import glamour.texture;
import glamour.vbo;

import onehundred;


class GraphicsBlob
{
  invariant
  {
    assert(verticesBuffer.buffer != 0);
    assert(textureBuffer.buffer != 0);
    assert(colorsBuffer.buffer != 0);
  }

  this(Texture2D texture)
  {
    this.texture = texture;
    data = new GraphicsData();

    verticesBuffer = new Buffer(data.vertices);
    textureBuffer = new Buffer(data.texCoords);
    colorsBuffer = new Buffer(data.colors);
  }
  
  this(Texture2D texture, GraphicsData data)
  {
    this.texture = texture;
    this.data = data;

    verticesBuffer = new Buffer(data.vertices);
    textureBuffer = new Buffer(data.texCoords);
    colorsBuffer = new Buffer(data.colors);
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

  void setVerticesTransform(mat4 verticesTransform) 
  {
    this.verticesTransform = verticesTransform;
  }
  
  void render(Shader shader, bool ignoreTexture, mat4 cameraTransform)
  {
    assert(data);

    Texture2D texture;
    if (framesAndDelays.length > 0)
    {
      currentFrameIndex++;
      currentFrameIndex = cast(int)(currentFrameIndex % framesAndDelays.length);

      texture = framesAndDelays[currentFrameIndex][0];
    }
    else
    {
      texture = this.texture;
    }
    texture.bind();

    verticesBuffer.set_data(data.vertices);
    textureBuffer.set_data(data.texCoords);
    colorsBuffer.set_data(data.colors);
    
    drawColoredTexture(shader, 
                       cameraTransform,
                       data.vertices, 
                       data.texCoords, 
                       data.colors,
                       verticesBuffer,
                       textureBuffer,
                       colorsBuffer,
                       ignoreTexture);
                       
    texture.unbind();
  }
  
  void setFramesAndDelays(Tuple!(Texture2D, int)[] framesAndDelays)
  {
    this.framesAndDelays = framesAndDelays;
    animationTime = framesAndDelays.map!(fd => fd[1]).sum;
  }

  Texture2D texture;
  MonoTime animationStartTime;
  Tuple!(Texture2D, int)[] framesAndDelays;
  int animationTime;
  int currentFrameIndex = -1;
  GraphicsData data;
  mat4 verticesTransform;
  Buffer verticesBuffer;
  Buffer textureBuffer;
  Buffer colorsBuffer;
}
