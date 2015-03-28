#version 330 core

vertex:
  in vec3 position;
  in vec2 texCoords;
  in vec4 color;
  
  out vec2 coords;
  out vec4 inColor;

  void main(void)
  {
    coords = texCoords;
    inColor = color;
    gl_Position = vec4(position, 1);
  }
  
fragment:
  uniform sampler2D textureMap;
  in vec2 coords;
  in vec4 inColor;
  out vec4 color;

  void main(void)
  { 
    color = texture(textureMap, coords) * inColor;
  }
