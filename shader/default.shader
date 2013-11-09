#version 330 core

vertex:
  layout(location = 0) in vec2 position;
  void main(void)
  {
    gl_Position = vec4(position, 0, 1);
  }

fragment:
  out vec3 color;
  void main(void)
  {
    color = vec3(1, 0, 0);
  }
  