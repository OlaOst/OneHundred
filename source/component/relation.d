module component.relation;

import artemisd.all;
import gl3n.linalg;


abstract class Relation : Component
{
  mixin TypeDecl;
  
  Entity[] relations;
  
  alias relations this;
  
  this(Entity[] relations)
  {
    this.relations = relations;
  }
}
