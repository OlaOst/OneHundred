module entity;

import gl3n.linalg;

import components.collider;
import components.drawables.polygon;
import components.drawables.sprite;
import components.drawables.text;
import components.input;
import components.sound;


class Entity
{
  double[string] scalars;
  vec2[string] vectors;
  vec4[string] bigVectors;
  
  // temp drawable stuff
  Polygon polygon;
  Text text;
  Sprite sprite;
  
  // temp stuff
  Input input;
  string editText;
  Sound sound;
  Collider collider;
  
  bool toBeRemoved = false;
  
  static long idCounter = 0;
  immutable long id;
  
  this()
  {
    id = idCounter++;
  }
  
  string debugInfo()
  {
    return "id: " ~ id.to!string ~ "\nposition: " ~ vectors["position"].to!string;
  }
}
