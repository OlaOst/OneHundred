module graphicscollector;

import gl3n.linalg;
import glamour.texture;

import camera;
import renderer.renderer;
import systemset;
import systems.polygongraphics;
import systems.spritegraphics;
import systems.textgraphics;


void collectFromGraphicsAndRender(SystemSet systemSet, Renderer renderer, Camera camera)
{
  vec3[][string] vertices;
  vec4[][string] colors;
  vec2[][string] texCoords;
  Texture2D[string] textureSet;
  
  foreach (key, value; systemSet.polygonGraphics.vertices)
    vertices[key] = value;
  foreach (key, value; systemSet.spriteGraphics.vertices)
    vertices[key] = value;
  foreach (key, value; systemSet.textGraphics.vertices)
    vertices[key] = value;
  
  foreach (key, value; systemSet.polygonGraphics.colors)
    colors[key] = value;
  foreach (key, value; systemSet.spriteGraphics.colors)
    colors[key] = value;
  foreach (key, value; systemSet.textGraphics.colors)
    colors[key] = value;
    
  foreach (key, value; systemSet.spriteGraphics.texCoords)
    texCoords[key] = value;
  foreach (key, value; systemSet.textGraphics.texCoords)
    texCoords[key] = value;
  
  foreach (key, value; systemSet.spriteGraphics.textureSet)
    textureSet[key] = value;
  //foreach (key, value; systemSet.textGraphics.textureSet)
    //textureSet[key] = value;
  textureSet["text"] = systemSet.textGraphics.textRenderer.atlas;

  renderer.render(camera.transform, vertices, colors, texCoords, textureSet);
}
