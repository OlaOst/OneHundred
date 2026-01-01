module camera;

import inmath.linalg;


class Camera
{
  vec3 position = vec3(0.0, 0.0, 0.0);
  double zoom = 0.1;
  
  vec3 transform(vec3 vector)
  {
    return vector * (1.0 / zoom) * 2.0 + position;
  }
  
  mat4 transform()
  {
    return mat4.identity.translation(-position.x, -position.y, -position.z)
                        .scale(zoom, zoom, zoom);
  }
  
  vec3 getWorldPositionFromScreenCoordinates(vec2 screenCoordinates, int xres, int yres)
  {
    return transform(vec3(screenCoordinates.x / cast(float)xres - 0.5,
                          0.5 - screenCoordinates.y / cast(float)yres,
                          0.0));
  }
}
