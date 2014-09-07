module components.drawable;

import gl3n.linalg;


class Drawable
{
  vec2 position;
  double angle;
  
  /*this(vec2 position, double angle)
  {
    this.position = position;
    this.angle = angle;
  }*/
}

// commonly used bases for triangles and rectangles
static immutable vec2[] baseTriangle = [vec2(-1.0, -1.0),
                                        vec2( 1.0, -1.0),
                                        vec2( 0.0,  1.0)];
                                        
static immutable vec2[] baseSquare = [vec2(-1.0, -1.0),
                                      vec2( 1.0, -1.0),
                                      vec2( 1.0,  1.0),
                                      vec2( 1.0,  1.0),
                                      vec2(-1.0,  1.0),
                                      vec2(-1.0, -1.0)];

static immutable vec2[] baseTexCoordsSquare = [vec2(0.0, 0.0), 
                                               vec2(1.0, 0.0), 
                                               vec2(1.0, 1.0), 
                                               vec2(1.0, 1.0), 
                                               vec2(0.0, 1.0), 
                                               vec2(0.0, 0.0)];