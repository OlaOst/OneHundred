module renderer.baseshapes;

import gl3n.linalg;


// commonly used bases for triangles and rectangles
static immutable vec3[] baseTriangle = [vec3(-1.0, -1.0, 0.0),
                                        vec3( 1.0, -1.0, 0.0),
                                        vec3( 0.0,  1.0, 0.0)];
                                        
static immutable vec3[] baseSquare = [vec3(-1.0, -1.0, 0.0),
                                      vec3( 1.0, -1.0, 0.0),
                                      vec3( 1.0,  1.0, 0.0),
                                      vec3( 1.0,  1.0, 0.0),
                                      vec3(-1.0,  1.0, 0.0),
                                      vec3(-1.0, -1.0, 0.0)];
                                      
static immutable vec3[] textSquare = [vec3(0.0, -0.5, 0.0),
                                      vec3(1.0, -0.5, 0.0),
                                      vec3(1.0,  0.5, 0.0),
                                      vec3(1.0,  0.5, 0.0),
                                      vec3(0.0,  0.5, 0.0),
                                      vec3(0.0, -0.5, 0.0)];

static immutable vec2[] baseTexCoordsSquare = [vec2(0.0, 0.0), 
                                               vec2(1.0, 0.0), 
                                               vec2(1.0, 1.0), 
                                               vec2(1.0, 1.0), 
                                               vec2(0.0, 1.0), 
                                               vec2(0.0, 0.0)];
