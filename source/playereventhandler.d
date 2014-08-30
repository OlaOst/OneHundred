module playereventhandler;

import gl3n.linalg;

import components.input;
import entity;
import entityfactory.entities;
import systemset;
import timer;


void handlePlayerRotateActions(Input playerInput, ref double torque)
{
  playerInput.setAction("rotateCounterClockwise", rotateCounterClockwise);
  playerInput.setAction("rotateClockwise", rotateClockwise);
  
  if (rotateCounterClockwise) torque += 1.0;
  if (rotateClockwise) torque -= 1.0;
}

void handlePlayerAccelerateActions(Input playerInput, ref vec2 force, double angle)
{
  playerInput.setAction("accelerate", accelerate);
  playerInput.setAction("decelerate", decelerate);
  
  if (accelerate) force += vec2(cos(angle), sin(angle)) * 0.5;
  if (decelerate) force -= vec2(cos(angle), sin(angle)) * 0.5;
}

void handlePlayerFireAction(Entity player, SystemSet systemSet, ref Entity[] npcs, Timer timer)
{
  systemSet.inputHandler.getComponent(player).setAction("fire", fire);
  
  static float reloadTimeLeft = 0.0;
  if (fire && reloadTimeLeft <= 0.0)
  {
    auto angle = player.values["angle"].to!float;
    
    auto bullet = createBullet(vec2(player.values["position"].to!(float[2])), 
                               angle, 
                               vec2(player.values["velocity"].to!(float[2])) + vec2(cos(angle), sin(angle)) * 5.0,
                               5.0);
    systemSet.collisionHandler.getComponent(bullet).spawner = player;
    systemSet.addEntity(bullet);
    npcs ~= bullet;
    reloadTimeLeft = 0.1;
  }
  else if (reloadTimeLeft > 0.0)
  {
    reloadTimeLeft -= timer.frameTime;
  }
}

bool fire = false;
bool accelerate = false;
bool decelerate = false;
bool rotateCounterClockwise = false;
bool rotateClockwise = false;
