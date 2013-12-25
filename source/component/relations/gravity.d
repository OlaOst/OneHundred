module component.relations.gravity;

import artemisd.all;
import gl3n.linalg;

import component.relation;


final class Gravity : Relation
{
  mixin TypeDecl;
  
  this(Entity[] relations)
  {
    super(relations);
  }
}
