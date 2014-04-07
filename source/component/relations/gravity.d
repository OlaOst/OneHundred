module component.relations.gravity;

import std.algorithm;

import gl3n.linalg;

import component.relation;


class Gravity
{
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
      gravityForce = relations.filter!(relation => relation.vectors["position"] && 
                                                   relation.scalars["mass"])
                              .map!(relation => getGravityForce(relation.vectors["position"], 
                                                                position, 
                                                                relation.scalars["mass"],
                                                                mass))
                              .reduce!"a+b";
    }
    
    return gravityForce;
  }
}
