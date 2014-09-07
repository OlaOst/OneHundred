module systemset;

import entity;
import systems.collisionhandler;
import systems.graphics;
import systems.inputhandler;
import systems.physics;
import systems.soundsystem;
import systems.timehandler;
import timer;


class SystemSet
{
  Graphics graphics;
  Physics physics;
  InputHandler inputHandler;
  CollisionHandler collisionHandler;
  SoundSystem soundSystem;
  TimeHandler timeHandler;
  
  this(int xres, int yres)
  {
    graphics = new Graphics(xres, yres);
    physics = new Physics();
    inputHandler = new InputHandler();
    collisionHandler = new CollisionHandler();
    soundSystem = new SoundSystem();
    timeHandler = new TimeHandler();
  }
  
  void close()
  {
    graphics.textRenderer.close();
    soundSystem.silence();
  }
  
  void addEntity(Entity entity)
  {
    graphics.addEntity(entity);
    physics.addEntity(entity);
    inputHandler.addEntity(entity);
    collisionHandler.addEntity(entity);
    soundSystem.addEntity(entity);
    timeHandler.addEntity(entity);
  }
  
  void removeEntity(Entity entity)
  {
    graphics.removeEntity(entity);
    physics.removeEntity(entity);
    inputHandler.removeEntity(entity);
    collisionHandler.removeEntity(entity);
    soundSystem.removeEntity(entity);
    timeHandler.removeEntity(entity);
  }
  
  void update(Timer timer)
  {
    physics.setTimer(timer);
    timeHandler.setTimer(timer);
    
    inputHandler.update();
    collisionHandler.update();
    physics.update();
    soundSystem.update();
    timeHandler.update();
    graphics.update();
  }
}
