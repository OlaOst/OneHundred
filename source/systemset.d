module systemset;

import std.datetime;
import std.string;

import entity;
import systems.collisionhandler;
import systems.graphics;
import systems.inputhandler;
import systems.physics;
import systems.polygongraphics;
import systems.soundsystem;
import systems.spritegraphics;
import systems.textgraphics;
import systems.timehandler;
import timer;


class SystemSet
{
  Graphics graphics;
  PolygonGraphics polygonGraphics;
  SpriteGraphics spriteGraphics;
  TextGraphics textGraphics;
  Physics physics;
  InputHandler inputHandler;
  CollisionHandler collisionHandler;
  SoundSystem soundSystem;
  TimeHandler timeHandler;
  
  this(int xres, int yres)
  {
    graphics = new Graphics(xres, yres);
    polygonGraphics = new PolygonGraphics(xres, yres, graphics.camera);
    spriteGraphics = new SpriteGraphics(xres, yres, graphics.camera);
    textGraphics = new TextGraphics(xres, yres, graphics.camera);
    physics = new Physics();
    inputHandler = new InputHandler();
    collisionHandler = new CollisionHandler();
    soundSystem = new SoundSystem();
    timeHandler = new TimeHandler();
  }
  
  void close()
  {
    textGraphics.textRenderer.close();
    soundSystem.silence();
  }
  
  void addEntity(Entity entity)
  {
    graphics.addEntity(entity);
    polygonGraphics.addEntity(entity);
    spriteGraphics.addEntity(entity);
    textGraphics.addEntity(entity);
    physics.addEntity(entity);
    inputHandler.addEntity(entity);
    collisionHandler.addEntity(entity);
    soundSystem.addEntity(entity);
    timeHandler.addEntity(entity);
  }
  
  void removeEntity(Entity entity)
  {
    graphics.removeEntity(entity);
    polygonGraphics.removeEntity(entity);
    spriteGraphics.removeEntity(entity);
    textGraphics.removeEntity(entity);
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
    
    StopWatch combinedGraphicsTimer;
    combinedGraphicsTimer.start();
    graphics.update();
    polygonGraphics.update();
    spriteGraphics.update();
    textGraphics.update();
    graphics.debugText = format("graphics timings: %s", combinedGraphicsTimer.peek.usecs*0.001);
  }
}
