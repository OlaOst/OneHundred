module systems.npchandler;

import std;

import bindbc.sdl;
import inmath.linalg;

import onehundred;


class NpcHandler : System!Npc
{
  this(InputHandler inputHandler)
  {
    this.inputHandler = inputHandler;
  }
  
  bool canAddEntity(Entity entity)
  {
    if (entity.has("fullName"))
      potentialTargetEntities ~= entity; // TODO: register all or only those with TargetType?
    return entity.has("npcTarget");
  }

  Npc makeComponent(Entity entity)
  {
    auto targetEntityMatches = potentialTargetEntities.filter!(potentialTargetEntity => 
      potentialTargetEntity.get!string("fullName") == entity.get!string("npcTarget")).array;
    enforce(!targetEntityMatches.empty);
    return new Npc(targetEntityMatches.front);
  }

  void updateValues() {}

  void updateEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      auto npcComponent = components[index];
      
      if (entity.get!string("fullName").endsWith(".engine"))
      {
        auto inputComponent = inputHandler.getComponent(entity);
        
        auto posToTarget = entity.get!vec3("position") - npcComponent.target.get!vec3("position");
        auto velToTarget = entity.get!vec3("velocity") - npcComponent.target.get!vec3("velocity");
        auto angleFromTarget = atan2(posToTarget.y, posToTarget.x);
        
        auto angleDiff = (entity.get!double("angle") - angleFromTarget);
        if (angleDiff > PI)
          angleDiff -= PI*2;
        else if (angleDiff < -PI)
          angleDiff += PI*2;
        
        if (angleDiff.abs < 0.1 || angleDiff.abs > PI*0.9)
        {
          inputComponent.resetAction("rotateClockwise");
          inputComponent.resetAction("rotateCounterClockwise");
          
          // accelerate towards set distance from target
          if (posToTarget.length > 5.0 && (velToTarget.length < 4.0 || 
              velToTarget.dot(posToTarget) > 0.0))
          {
            inputComponent.setAction("accelerate");
            inputComponent.resetAction("decelerate");
          }
          else if (posToTarget.length < 2.0 && (velToTarget.length < 4.0) || 
                   velToTarget.dot(posToTarget) < 0.0)
          {
            inputComponent.resetAction("accelerate");
            inputComponent.setAction("decelerate");
          }
          else // TODO: adjust speed relative to target speed
          {
            inputComponent.resetAction("accelerate");
            inputComponent.resetAction("decelerate");
          }
        }
        else if (angleDiff < 0 && entity.get!double("rotation") < 1.0)
        {
          inputComponent.setAction("rotateClockwise");
          inputComponent.resetAction("rotateCounterClockwise");
        }
        else if (angleDiff > 0 && entity.get!double("rotation") > -1.0)
        {
          inputComponent.resetAction("rotateClockwise");
          inputComponent.setAction("rotateCounterClockwise");
        }
      }
    }
  }

  void updateFromEntities() {}
  
  Entity[] potentialTargetEntities;
  InputHandler inputHandler;
}
