module playereventhandler;

import std.algorithm;

import gl3n.linalg;

import components.input;
import converters;
import entity;
import entityfactory.entities;
import systemset;


void handlePlayerFireAction(Entity player, SystemSet systemSet, ref Entity[] npcs)
{
  if (!systemSet.inputHandler.hasComponent(player))
    return;
    
  fire = systemSet.inputHandler.getComponent(player).isActionSet("fire");
  
  static float reloadTimeLeft = 0.0;
  if (fire && reloadTimeLeft <= 0.0)
  {
    auto angle = player.get!double("angle");
    
    auto bullet = createBullet(player.get!vec3("position"), 
                               angle, 
                               player.get!vec3("velocity") + vec3(vec2FromAngle(angle), 0.0) * 5.0,
                               5.0,
                               player.id);
    systemSet.addEntity(bullet);
    
    assert(systemSet.collisionHandler.getComponent(bullet).colliderIdsToIgnore.canFind(player.id));
    
    npcs ~= bullet;
    reloadTimeLeft = 0.1;
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
