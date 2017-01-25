#version 330 core

vertex:
  uniform mat4 transform;

  in vec3 position;
  in vec4 color;
  in vec3 barycentric;
  
  out vec2 coords;
  out vec4 inColor;
  out vec3 inBarycentric;

  void main(void)
  {
    inColor = color;
    inBarycentric = barycentric;
    gl_Position = transform * vec4(position, 1);
  }
  
fragment:
  in vec4 inColor;
  in vec3 inBarycentric;
  out vec4 color;

  void main(void)
  { 
    // Given a point P = P0·s + P1·t + P2·(1-s-t) in the triangle (P0, P1, P2), the pixel in the triangle is only flipped if (s/2 + t)² < t
    // find barycentric coords
    // flip if (s/2 + t)^2 < t

    float s = inBarycentric.z;
    float t = inBarycentric.x;
    
    float check = (s/2 + t) * (s/2 + t);
    
    //color = vec4(0, 0, 0, 0);
    
    //color = vec4(inBarycentric.x, inColor.g, inColor.b, 0);
    
    if (check < t)
      //color = inColor;
      color = vec4(1+inColor.r*0.1,1,1,1);
    else
      color = vec4(0,0,0,0);
  }
