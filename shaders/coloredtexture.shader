#version 330 core

vertex:
  uniform mat4 transform;

  in vec3 position;
  in vec2 texCoords;
  in vec4 color;
  
  out vec2 coords;
  out vec4 inColor;

  void main(void)
  {
    coords = texCoords;
    inColor = color;
    gl_Position = transform * vec4(position, 1);
  }
  
fragment:
  uniform sampler2D textureMap;
  uniform bool ignoreTexture;
  in vec2 coords;
  in vec4 inColor;
  out vec4 color;

  void main(void)
  { 
    vec4 textureColor = texture(textureMap, coords);
    
    float alpha = inColor.a * textureColor.a;
    
    if (ignoreTexture)
      color = inColor;
    else
      color = vec4(alpha * inColor.rgb + (1-alpha) * textureColor.rgb, textureColor.a);
  }
