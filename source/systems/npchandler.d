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
  
  void setPlayerEntity(Entity playerEntity)
  {
    this.playerEntity = playerEntity;
  }
  
  bool canAddEntity(Entity entity)
  {
    return entity.has("npcTarget");
  }

  Npc makeComponent(Entity entity)
  {
    auto npcTargetName = entity.get!string("npcTarget");    
    
    entity.values.keys.zip(entity.values.values).each!writeln; //.map!(kv => kv.key ~ ": " ~ kv.value).each!writeln;
    
    //debug writeln("npchandler makeComponent for entity ", entity.get!string("fullname"), " with npcTargetName ", npcTargetName);
    
    return new Npc(npcTargetName);
  }

  void updateValues()
  {
  }

  void updateEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      auto npcComponent = components[index];
      if (entity.get!string("fullName").endsWith(".engine"))
      {
        auto inputComponent = inputHandler.getComponent(entity);
        
        debug writeln("npchandler updating npcengineentity ", entity.get!string("fullname"));
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
        auto positionRelativeToPlayer = position - playerEntity.get!vec3("position");
        auto velocityRelativeToPlayer = velocity - playerEntity.get!vec3("velocity");
        auto angleFromPlayer = atan2(positionRelativeToPlayer.y, positionRelativeToPlayer.x);
        
        auto angleDiff = (angle - angleFromPlayer);
        if (angleDiff > PI)
          angleDiff -= PI*2;
        else if (angleDiff < -PI)
          angleDiff += PI*2;
        
        if (angleDiff.abs < 0.1 || angleDiff.abs > PI*0.9)
        {
          debug writeln("slowing turn");
          // dampen rotation when there is no rotation torque
          torque -= entity.get!double("rotation") * engineTorque;
          
          inputComponent.resetAction("rotateClockwise");
          inputComponent.resetAction("rotateCounterClockwise");
          
          // accelerate towards set distance from target
          
          if (positionRelativeToPlayer.length > 5.0 && (velocityRelativeToPlayer.length < 4.0 || velocityRelativeToPlayer.dot(positionRelativeToPlayer) > 0.0))
          {
            debug writeln("accelerating towards target");
            //force += engineForce;
            inputComponent.setAction("accelerate");
            inputComponent.resetAction("decelerate");
          }
          else if (positionRelativeToPlayer.length < 2.0 && (velocityRelativeToPlayer.length < 4.0) || velocityRelativeToPlayer.dot(positionRelativeToPlayer) < 0.0)
          {
            debug writeln("accelerating away from target");
            //force -= engineForce;
            inputComponent.resetAction("accelerate");
            inputComponent.setAction("decelerate");
          }
          else // TODO: adjust speed relative to target speed
          {
            debug writeln("slowing down");
            force -= entity.get!double("velocity") * engineForce;
            inputComponent.resetAction("accelerate");
            inputComponent.resetAction("decelerate");
          }
        }
        else if (angleDiff < 0 && rotation < 1.0)
        {
          debug writeln("turning right");
          //torque += engineTorque;
          inputComponent.setAction("rotateClockwise");
          inputComponent.resetAction("rotateCounterClockwise");
        }
        else if (angleDiff > 0 && rotation > -1.0)
        {
          debug writeln("turning left");
          //torque -= engineTorque;
          inputComponent.resetAction("rotateClockwise");
          inputComponent.setAction("rotateCounterClockwise");
        }
        else
        {
          debug writeln("wtf");
          // dampen rotation when there is no rotation torque
          //torque -= entity.get!double("rotation") * engineTorque;
        }
        
        debug writeln("npc angle ", angle, ", position relative to player ", positionRelativeToPlayer, ", angle from center ", angleFromCenter, ", angleDiff ", angleDiff, " engine torque ", engineTorque, " final torque ", torque, " final force ", force);
        
        entity["torque"] = torque;
        entity["force"] = force;
      }
    }
  }

  void updateFromEntities() {}
  
  Entity playerEntity;  
  InputHandler inputHandler;
}
