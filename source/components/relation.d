module components.relation;

import entity;


mixin template Relation()
{
  import entity;
  Entity[] relations;
  
  alias relations this;
  
  this(Entity[] relations)
  {
    this.relations = relations;
  }
}
