module renderer.textoutlinerenderer;

import derelict.opengl3.gl3;
import glamour.shader;
import glamour.util;
import glamour.vbo;
import gl3n.linalg;


public void drawTextOutline(Shader[string] shaderSet, mat4 transform,
                            vec3[] vertices, vec2[] texCoords, vec4[] colors)
{
  assert(vertices.length == texCoords.length);
  assert(vertices.length == colors.length);

  auto verticesBuffer = new Buffer(vertices);
  auto textureBuffer = new Buffer(texCoords);
  auto colorsBuffer = new Buffer(colors);
  auto blankColorBuffer = new Buffer([vec4(0,0,0,0)]);
  //glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD);
  //glBlendFuncSeparate(GL_ONE, GL_ONE, GL_ONE, GL_ZERO);
  //glBlendFunc(GL_ONE, GL_ONE);
  
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
  
  
  // draw with updated stencil that should clip out anything outside the letter outline
  //shaderSet["coloredtexture"].bind();
  //shaderSet["coloredtexture"].uniform("transform", transform);
  //shaderSet["coloredtexture"].uniform1i("ignoreTexture", true);
  
  glStencilFunc(GL_NOTEQUAL, 0, 0xff);
  glStencilMask(0x00);
  
  //verticesBuffer.bind(shaderSet["coloredtexture"], "position", GL_FLOAT, 3, 0, 0);
  //textureBuffer.bind(shaderSet["coloredtexture"], "texCoords", GL_FLOAT, 2, 0, 0);
  colorsBuffer.bind(shaderSet["coloredtexture"], "color", GL_FLOAT, 4, 0, 0);

  checkgl!glDrawArrays(GL_TRIANGLES, 0, cast(int)(vertices.length));
  
  verticesBuffer.remove();
  textureBuffer.remove();
  colorsBuffer.remove();
  blankColorBuffer.remove();
  
  glDisable(GL_STENCIL_TEST);
}
