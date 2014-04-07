module entity;

import gl3n.linalg;

import component.collider;
import component.drawables.polygon;
import component.drawables.text;
import component.input;
import component.sound;

class Entity
{
  double[string] scalars;
  vec2[string] vectors;
  vec4[string] bigVectors;
  
  // temp drawable stuff
  Polygon polygon;
  Text text;
  
  // temp input mapping
  Input input;
  
  Sound sound;
  
  Collider collider;
  
  static long idCounter = 0;
  immutable long id;
  
  this()
  {
    id = idCounter++;
  }
}
