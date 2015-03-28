#version 330 core

vertex:
  in vec3 position;
  in vec4 color;
  
  out vec4 fragmentColor;
  
  void main(void)
  {
    fragmentColor = color;  
    gl_Position = vec4(position, 1);
  }

fragment:
  in vec4 fragmentColor;
  out vec4 color;
  
  void main(void)
  {
    color = fragmentColor;
    //color = gl_FragCoord * 0.001;
  }
  