module components.relations.inspectvalues;

import components.relation;
import entity;


class InspectValues : Relation
{
  Entity source;
  
  this(Entity source)
  {
    this.source = source;
  }
  
  void updateValues(Entity target)
  {
    source.values["text"] = target.debugInfo;
  }
}
