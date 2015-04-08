module renderer.coloredtexturerenderer;

import derelict.opengl3.gl3;
import glamour.shader;
import glamour.vbo;
import gl3n.linalg;


public void drawColoredTexture(Shader shader, mat4 transform, vec3[] vertices, vec2[] texCoords, vec4[] colors)
{
  assert(vertices.length == texCoords.length);
  assert(vertices.length == colors.length);
  
  auto verticesBuffer = new Buffer(vertices);
  auto textureBuffer = new Buffer(texCoords);
  auto colorsBuffer = new Buffer(colors);
  
  shader.bind();
  
  shader.uniform("transform", transform);
  
  verticesBuffer.bind(shader, "position", GL_FLOAT, 3, 0, 0);
  textureBuffer.bind(shader, "texCoords", GL_FLOAT, 2, 0, 0);
  colorsBuffer.bind(shader, "color", GL_FLOAT, 4, 0, 0);
  
  checkgl!glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices.length));
  
  verticesBuffer.remove();
  textureBuffer.remove();
  colorsBuffer.remove();
}
