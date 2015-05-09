module renderer.polygonrenderer;

import derelict.opengl3.gl3;
import glamour.vbo;
import gl3n.linalg;


public void drawPolygons(Shader shader, mat4 transform, vec3[] vertices, vec4[] colors)
{
  assert(vertices.length == colors.length);

  auto verticesBuffer = new Buffer(vertices);
  auto colorsBuffer = new Buffer(colors);

  shader.bind();

  shader.uniform("transform", transform);

  verticesBuffer.bind(shader, "position", GL_FLOAT, 3, 0, 0);
  colorsBuffer.bind(shader, "color", GL_FLOAT, 4, 0, 0);

  checkgl!glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices.length));

  verticesBuffer.remove();
  colorsBuffer.remove();
}
