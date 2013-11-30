#version 330 core

vertex:
  layout(location = 0) in vec2 position;
  layout(location = 1) in vec3 color;
  
  out vec3 fragmentColor;
  
  void main(void)
  {
    fragmentColor = color;
    
    gl_Position = vec4(position, 0, 1);
  }

fragment:
  in vec3 fragmentColor;
  out vec3 color;
  
  void main(void)
  {
    color = fragmentColor;
    //color = gl_FragCoord * 0.001;
  }
  