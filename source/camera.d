module camera;

import gl3n.linalg;


class Camera
{
  vec3 position = vec3(0.0, 0.0, 0.0);
  float zoom = 0.3;
  
  vec3 transform(vec3 vector)
  {
    return vector * (1.0 / zoom) * 2.0 + position;
  }
}
