module component.relations.gravity;

import std.algorithm;

import artemisd.all;
import gl3n.linalg;

import component.mass;
import component.position;
import component.relation;


final class Gravity : Component
{
  mixin TypeDecl;
  mixin Relation;
  
  static vec2 getGravityForce(vec2 firstPosition, 
                              vec2 otherPosition, 
                              double firstMass, 
                              double otherMass)
  {
    return (firstPosition-otherPosition).normalized * 
           ((firstMass*otherMass) / (firstPosition-otherPosition).magnitude^^2);
  }
  
  vec2 getAccumulatedGravityForce(vec2 position, float mass)
  {
    vec2 gravityForce = vec2(0.0, 0.0);
    
    if (relations.length > 0)
    {
      gravityForce = relations.filter!(relation => relation.getComponent!Position && 
                                                   relation.getComponent!Mass)
                              .map!(relation => getGravityForce(relation.getComponent!Position, 
                                                                position, 
                                                                relation.getComponent!Mass, 
                                                                mass))
                              .reduce!"a+b";
    }
    
    return gravityForce;
  }
}
