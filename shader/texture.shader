#version 330 core

vertex:
  layout(location = 0) in vec2 position;
  layout(location = 1) in vec2 texCoords;

  out vec2 coords;

  void main(void)
  {
    coords = texCoords.st;
    
    gl_Position = vec4(position, 0, 1);
  }
  
fragment:
  uniform sampler2D textureMap;
  in vec2 coords;
  out vec4 color;

  void main(void)
  {  
    color = texture2D(textureMap, coords.st).rgba;
    //color = vec4(1.0, 0.0, 0.0, 1.0);
  }
