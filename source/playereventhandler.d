module playereventhandler;

import gl3n.linalg;

import components.input;
import entity;
import entityfactory.entities;
import systemset;
import timer;


void handlePlayerRotateActions(Input playerInput, ref double torque)
{
  playerInput.setAction("rotateLeft", rotateLeft);
  playerInput.setAction("rotateRight", rotateRight);
  
  if (rotateLeft) torque -= 1.0;
  if (rotateRight) torque += 1.0;
}

void handlePlayerAccelerateActions(Input playerInput, ref vec2 force, double angle)
{
  playerInput.setAction("accelerate", accelerate);
  playerInput.setAction("decelerate", decelerate);
  
  if (accelerate) force += vec2(sin(-angle), cos(-angle)) * 0.5;
  if (decelerate) force -= vec2(sin(-angle), cos(-angle)) * 0.5;
}

void handlePlayerFireAction(Entity player, SystemSet systemSet, ref Entity[] npcs, Timer timer)
{
  player.input.setAction("fire", fire);
  
  static float reloadTimeLeft = 0.0;
  if (fire && reloadTimeLeft <= 0.0)
  {
    auto bullet = createBullet(player.vectors["position"], 
                               player.scalars["angle"], 
                               player.vectors["velocity"],
                               5.0);
    bullet.collider.spawner = player;
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
bool rotateLeft = false;
bool rotateRight = false;
