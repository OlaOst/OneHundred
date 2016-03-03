module renderer.graphicsblob;

import gl3n.linalg;

import glamour.shader;
import glamour.texture;

import renderer.coloredtexturerenderer;


class GraphicsBlob
{
  this(Texture2D texture)
  {
    this.texture = texture;
  }
  
  void reset()
  {
    vertices.length = 0;
    colors.length = 0;
    texCoords.length = 0;
  }
  
  void render(Shader shader, bool ignoreTexture, mat4 cameraTransform)
  {
    assert(vertices.length == colors.length, vertices.length.to!string ~ " vertices vs " ~ colors.length.to!string ~ " colors");
    assert(vertices.length == texCoords.length);
    
    texture.bind();
    
    drawColoredTexture(shader, 
                       cameraTransform,
                       vertices, 
                       texCoords, 
                       colors,
                       ignoreTexture);
                       
    texture.unbind();
  }
  
  Texture2D texture;
  vec3[] vertices;
  vec4[] colors;
  vec2[] texCoords;
}
