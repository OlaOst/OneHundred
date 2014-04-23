module systemset;

import entity;
import systems.collisionhandler;
import systems.graphics;
import systems.inputhandler;
import systems.physics;
import systems.soundsystem;
import timer;


class SystemSet
{
  Graphics graphics;
  Physics physics;
  InputHandler inputHandler;
  CollisionHandler collisionHandler;
  SoundSystem soundSystem;
  
  this(int xres, int yres)
  {
    graphics = new Graphics(xres, yres);
    physics = new Physics();
    inputHandler = new InputHandler();
    collisionHandler = new CollisionHandler();
    soundSystem = new SoundSystem();
  }
  
  void close()
  {
    collisionHandler.close();
    graphics.close();
    soundSystem.silence();
  }
  
  void addEntity(Entity entity)
  {
    graphics.addEntity(entity);
    physics.addEntity(entity);
    inputHandler.addEntity(entity);
    collisionHandler.addEntity(entity);
    soundSystem.addEntity(entity);
  }
  
  void removeEntity(Entity entity)
  {
    graphics.removeEntity(entity);
    physics.removeEntity(entity);
    inputHandler.removeEntity(entity);
    collisionHandler.removeEntity(entity);
    soundSystem.removeEntity(entity);
  }
  
  void update(Timer timer)
  {
    physics.setTimer(timer);
    
    collisionHandler.update();
    physics.updateFromEntities();
    
    graphics.update();
    physics.update();
    inputHandler.update();
    soundSystem.update();
    
    physics.updateEntities();
    graphics.updateFromEntities();
    collisionHandler.updateFromEntities();
  }
}
