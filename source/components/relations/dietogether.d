module components.relations.dietogether;

import components.relation;
import entity;


class DieTogether : Relation
{
  Entity source;
  
  this(Entity source)
  {
    this.source = source;
  }
  
  void updateValues(Entity target)
  {
    source.toBeRemoved = target.toBeRemoved;
  }
}
