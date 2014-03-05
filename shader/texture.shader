#version 330 core

vertex:
  in vec2 position;
  in vec2 texCoords;

  out vec2 coords;

  void main(void)
  {
    coords = texCoords;
    gl_Position = vec4(position, 0, 1);
  }
  
fragment:
  uniform sampler2D textureMap;
  in vec2 coords;
  out vec4 color;

  void main(void)
  {  
    color = texture(textureMap, coords).rgba;
  }
