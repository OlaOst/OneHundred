module playereventhandler;

import gl3n.linalg;

import components.input;
import converters;
import entity;
import entityfactory.entities;
import systemset;
import timer;


void handlePlayerFireAction(Entity player, SystemSet systemSet, ref Entity[] npcs)
{
  fire = systemSet.inputHandler.getComponent(player).isActionSet("fire");
  
  static float reloadTimeLeft = 0.0;
  if (fire && reloadTimeLeft <= 0.0)
  {
    auto angle = player.get!double("angle");
    
    auto bullet = createBullet(player.get!vec2("position"), 
                               angle, 
                               player.get!vec2("velocity") + vec2FromAngle(angle) * 5.0,
                               5.0,
                               player.id);
    systemSet.addEntity(bullet);
    
    assert(systemSet.collisionHandler.getComponent(bullet).spawner == player);
    
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
