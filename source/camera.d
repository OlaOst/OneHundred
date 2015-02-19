module camera;

import gl3n.linalg;


class Camera
{
  vec2 position = vec2(0.0, 0.0);
  float zoom = 0.3;
  
  vec2 transform(vec2 vector)
  {
    return vector * (1.0 / zoom) * 2.0 + position;
  }
}
