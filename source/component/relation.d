module component.relation;

import artemisd.all;


mixin template Relation()
{
  Entity[] relations;
  
  alias relations this;
  
  this(Entity[] relations)
  {
    this.relations = relations;
  }
}
