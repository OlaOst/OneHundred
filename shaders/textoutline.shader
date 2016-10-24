#version 330 core

vertex:
  uniform mat4 transform;

  in vec3 position;
  in vec4 color;
  
  out vec2 coords;
  out vec4 inColor;

  void main(void)
  {
    inColor = color;
    gl_Position = transform * vec4(position, 1);
  }
  
fragment:
  in vec4 inColor;
  out vec4 color;

  void main(void)
  { 
    color = vec4(inColor.r,0,0,0);
    //color = inColor;
    //color = inColor * 255;
    //color = vec4(inColor.rgb, 1.0/255.0);
    //color = vec4(1.0/255.0, 1.0/255.0, 1.0/255.0, 1.0/255.0);
    /*if (int(color.r * 255.0) % 2 == 0)
      color = vec4(1,1,1,1);
    else
      color = vec4(1,1,0,1);*/
  }
