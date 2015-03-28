module components.relations.dietogether;

import std.conv;

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
    source["ToBeRemoved"] = target.get!bool("ToBeRemoved");
  }
}
