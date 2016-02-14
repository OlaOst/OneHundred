module playereventhandler;

import std.algorithm;

import gl3n.linalg;

import components.input;
import converters;
import entity;
import entityfactory.entities;
import systemset;


void handlePlayerFireAction(Entity playerGun, SystemSet systemSet) //, ref Entity[] npcs)
{
  fire = systemSet.inputHandler.getComponent(playerGun).isActionSet("fire");
  
  static double reloadTimeLeft = 0.0;
  if (fire && reloadTimeLeft <= 0.0)
  {
    auto angle = playerGun.get!double("angle");
    
    auto bulletEntityGroup = createBulletEntityGroup(playerGun.get!vec3("position"), 
                                                     angle, 
                                                     playerGun.get!vec3("velocity") + 
                                                        vec3(vec2FromAngle(angle), 0.0) * 5.0,
                                                     5.0,
                                                     playerGun.id);
    
    foreach (bulletEntity; bulletEntityGroup)
    {
      bulletEntity["collisionfilter"] = "player.ship.*";
      systemSet.addEntity(bulletEntity);
    }
    
    assert(bulletEntityGroup.values.all!(bulletEntity => systemSet.collisionHandler
                                                                  .getComponent(bulletEntity)
                                                                  .colliderIdsToIgnore
                                                                  .canFind(playerGun.id)));
    
    //npcs ~= bulletEntityGroup;
    reloadTimeLeft = playerGun.get!double("reloadTime");
  }
  else if (reloadTimeLeft > 0.0)
  {
    reloadTimeLeft -= systemSet.physics.timer.frameTime;
  }
}

bool fire = false;
bool accelerate = false;
bool decelerate = false;
bool rotateCounterClockwise = false;
bool rotateClockwise = false;
