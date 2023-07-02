module systems.npchandler;

import std;

import bindbc.sdl;
import inmath.linalg;

import components.input;
import components.npc;
import converters;
import entity;
import navigationinput;
import system;
import systems.inputhandler;


class NpcHandler : System!Npc
{
  this(InputHandler inputHandler)
  {
    this.inputHandler = inputHandler;
  }
  
  bool canAddEntity(Entity entity)
  {
    if (entity.has("fullName"))
    {
      potentialTargetEntities ~= entity; // TODO: register all entities or add a TargetType value and only register those with a TargetType?
    }
    
    return entity.has("npcTarget");
  }

  Npc makeComponent(Entity entity)
  {
    auto targetEntityMatches = potentialTargetEntities.filter!(potentialTargetEntity => potentialTargetEntity.get!string("fullName") == entity.get!string("npcTarget")).array;
    
    enforce(!targetEntityMatches.empty);
    auto targetEntity = targetEntityMatches.front;
    
    return new Npc(targetEntity);
  }

  void updateValues()
  {
  }

  void updateEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      auto npcComponent = components[index];
      
      auto targetEntity = npcComponent.target;
      
      if (entity.get!string("fullName").endsWith(".engine"))
      {
        auto inputComponent = inputHandler.getComponent(entity);
        
        auto engineForce = entity.has("engineForce") ? entity.get!double("engineForce") : 1.0;
        auto engineTorque = entity.has("engineTorque") ? entity.get!double("engineTorque") : 1.0;
        
        auto angle = entity.get!double("angle");
        auto rotation = entity.get!double("rotation");
        auto torque = entity.get!double("torque");
        auto force = entity.get!double("force");
        // points toward angle 0 (up or left?)
        
        auto position = entity.get!vec3("position");
        auto velocity = entity.get!vec3("velocity");
        
        auto angleFromCenter = atan2(position.y, position.x);
        auto positionRelativeToTarget = position - targetEntity.get!vec3("position");
        auto velocityRelativeToTarget = velocity - targetEntity.get!vec3("velocity");
        auto angleFromTarget = atan2(positionRelativeToTarget.y, positionRelativeToTarget.x);
        
        auto angleDiff = (angle - angleFromTarget);
        if (angleDiff > PI)
          angleDiff -= PI*2;
        else if (angleDiff < -PI)
          angleDiff += PI*2;
        
        if (angleDiff.abs < 0.1 || angleDiff.abs > PI*0.9)
        {
          // dampen rotation when there is no rotation torque
          torque -= entity.get!double("rotation") * engineTorque;
          
          inputComponent.resetAction("rotateClockwise");
          inputComponent.resetAction("rotateCounterClockwise");
          
          // accelerate towards set distance from target
          if (positionRelativeToTarget.length > 5.0 && (velocityRelativeToTarget.length < 4.0 || velocityRelativeToTarget.dot(positionRelativeToTarget) > 0.0))
          {
            inputComponent.setAction("accelerate");
            inputComponent.resetAction("decelerate");
          }
          else if (positionRelativeToTarget.length < 2.0 && (velocityRelativeToTarget.length < 4.0) || velocityRelativeToTarget.dot(positionRelativeToTarget) < 0.0)
          {
            inputComponent.resetAction("accelerate");
            inputComponent.setAction("decelerate");
          }
          else // TODO: adjust speed relative to target speed
          {
            force -= entity.get!double("velocity") * engineForce;
            inputComponent.resetAction("accelerate");
            inputComponent.resetAction("decelerate");
          }
        }
        else if (angleDiff < 0 && rotation < 1.0)
        {
          inputComponent.setAction("rotateClockwise");
          inputComponent.resetAction("rotateCounterClockwise");
        }
        else if (angleDiff > 0 && rotation > -1.0)
        {
          inputComponent.resetAction("rotateClockwise");
          inputComponent.setAction("rotateCounterClockwise");
        }
        
        entity["torque"] = torque;
        entity["force"] = force;
      }
    }
  }

  void updateFromEntities() {}
  
  Entity[] potentialTargetEntities;
  InputHandler inputHandler;
}
