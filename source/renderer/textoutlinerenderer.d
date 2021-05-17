module renderer.textoutlinerenderer;

import std;

import bindbc.opengl;
import glamour.shader;
import glamour.util;
import glamour.vbo;
import gl3n.linalg;


public void drawTextOutline(Shader[string] shaderSet, mat4 transform,
                            vec3[] vertices, vec3[] controlVertices, 
                            vec2[] texCoords, vec4[] colors)
{
  assert(vertices.length == texCoords.length);
  assert(vertices.length == colors.length);

  auto verticesBuffer = new Buffer(vertices);
  auto textureBuffer = new Buffer(texCoords);
  auto colorsBuffer = new Buffer(colors);
  auto blankColorBuffer = new Buffer([vec4(0,0,0,0)].repeat(vertices.length).array);
  auto controlVerticesBuffer = new Buffer(controlVertices);
  auto barycenterBuffer = new Buffer([vec3(1,0,0), vec3(0,1,0), vec3(0,0,1)]
                          .cycle.take(controlVertices.length).array);
  
  // First pass, run invert on every triangle to get winding number outline in the stencil buffer
  glEnable(GL_STENCIL_TEST);
  
  glStencilMask(~0);
  glDisable(GL_SCISSOR_TEST);
  glClear(GL_STENCIL_BUFFER_BIT);
  
  glStencilFunc(GL_ALWAYS, 1, 0xff);
  glStencilOp(GL_KEEP, GL_KEEP, GL_INVERT);
  glStencilMask(0xff);
  
  shaderSet["coloredtexture"].bind();

  shaderSet["coloredtexture"].uniform("transform", transform);
  shaderSet["coloredtexture"].uniform1i("ignoreTexture", true);

  verticesBuffer.bind(shaderSet["coloredtexture"], "position", GL_FLOAT, 3, 0, 0);
  textureBuffer.bind(shaderSet["coloredtexture"], "texCoords", GL_FLOAT, 2, 0, 0);
  blankColorBuffer.bind(shaderSet["coloredtexture"], "color", GL_FLOAT, 4, 0, 0);

  checkgl!glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices.length));

  //version(OSX) {} else
    //verticesBuffer.remove();
  //colorsBuffer.remove();
  
  // second pass, draw with updated stencil that should clip out anything outside the letter outline
  
  glStencilFunc(GL_NOTEQUAL, 0, 0xff);
  glStencilMask(0x00);
  
  colorsBuffer.bind(shaderSet["coloredtexture"], "color", GL_FLOAT, 4, 0, 0);

  checkgl!glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices.length));
  
  glDisable(GL_STENCIL_TEST);
  
  // third pass, draw curve corrections on top of triangle lines
  // assume only quadratic segments
  // Given a point P = P0·s + P1·t + P2·(1-s-t) in the triangle (P0, P1, P2), 
  // the pixel in the triangle is only flipped if (s/2 + t)² < t
  // s and t are barycentric coords
  shaderSet["textquadratic"].bind();
  shaderSet["textquadratic"].uniform("transform", transform);
  controlVerticesBuffer.bind(shaderSet["textquadratic"], "position", GL_FLOAT, 3, 0, 0);
  colorsBuffer.bind(shaderSet["textquadratic"], "color", GL_FLOAT, 4, 0, 0);
  barycenterBuffer.bind(shaderSet["textquadratic"], "barycentric", GL_FLOAT, 3, 0, 0);
  checkgl!glDrawArrays(GL_TRIANGLES, 0, cast(int)(controlVertices.length));
  
  verticesBuffer.remove();
  textureBuffer.remove();
  colorsBuffer.remove();
  barycenterBuffer.remove();
  blankColorBuffer.remove();
  controlVerticesBuffer.remove();
}
