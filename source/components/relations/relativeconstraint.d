module components.relations.relativeconstraint;

import std;

import inmath.aabb;
import inmath.linalg;

import components.relation;
import converters;
import entity;


class RelativeConstraint(ValueType) : Relation
{
  Entity source;
  const string constraintName;
  const ValueType constraintValue;
  
  this(Entity source, string constraintName, ValueType constraintValue)
  {
    this.source = source;
    this.constraintName = constraintName;
    this.constraintValue = constraintValue;
  }
  
  void updateValues(Entity target)
  {
    static if(is(ValueType == double))
    {
      if (constraintName == "distance")
      {
        auto position = source.get!vec3("position");
        // assume physics etc systems have updated position here
        auto newPosition = position.normalized * constraintValue;

        source["position"] = newPosition;

        auto velocity = source.get!vec3("velocity");
        velocity += newPosition - position;
        source["velocity"] = velocity;
      }
      else if (constraintName == "speed")
      {
        auto velocity = source.get!vec3("velocity");
        // assume physics etc systems have updated velocity here
        auto newVelocity = velocity.normalized * constraintValue;

        source["velocity"] = newVelocity;
      }
      else
      {
        assert(0);
      }
    }
    else
      assert(0);
      
    //source[valueName] = newValue;
  }
}
