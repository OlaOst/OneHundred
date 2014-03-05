module component.drawable;

import artemisd.all;
import gl3n.linalg;


class Drawable : Component
{
  mixin TypeDecl;
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
                                      