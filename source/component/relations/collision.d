module component.relations.collision;

import artemisd.all;
import gl3n.linalg;

import component.relation;


final class Collision : Relation
{
  mixin TypeDecl;
  
  this(Entity[] relations)
  {
    super(relations);
  }
}
