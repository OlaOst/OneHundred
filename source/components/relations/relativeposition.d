module components.relations.relativeposition;

import gl3n.linalg;

import components.relation;
import converters;
import entity;


class RelativePosition : Relation
{
  Entity source;
  const vec2 relativePosition;
  
  this(Entity source, vec2 relativePosition)
  {
    this.source = source;
    this.relativePosition = relativePosition;
  }
  
  void updateValues(Entity target)
  {
    auto newPosition = target.values["position"].myTo!vec2 + relativePosition;
    source.values["position"] = newPosition.to!string;
  }
}
