module systemset;

import std.algorithm;
import std.datetime;
import std.range;
import std.string;

import entity;
import systems.collisionhandler;
import systems.graphics;
import systems.inputhandler;
import systems.physics;
import systems.polygongraphics;
import systems.relationhandler;
import systems.soundsystem;
import systems.spritegraphics;
import systems.textgraphics;
import systems.timehandler;
import timer;


class SystemSet
{
  Entity[] entities;
  Graphics graphics;
  PolygonGraphics polygonGraphics;
  SpriteGraphics spriteGraphics;
  TextGraphics textGraphics;
  Physics physics;
  InputHandler inputHandler;
  CollisionHandler collisionHandler;
  SoundSystem soundSystem;
  TimeHandler timeHandler;
  RelationHandler relationHandler;
  
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
    relationHandler = new RelationHandler();
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
    relationHandler.addEntity(entity);
    
    entities ~= entity;
  }
  
  private void removeEntity(Entity entity)
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
    relationHandler.removeEntity(entity);
    
    // swap last entity with the one to be deleted, then pop off the last entity
    //auto index = entities.countUntil(entity);
    //auto indexToMove = entities.length - 1;
    //entities[index] = entities[indexToMove];
    //entities.popBack();
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
    relationHandler.update();
    
    StopWatch combinedGraphicsTimer;
    combinedGraphicsTimer.start();
    graphics.update();
    polygonGraphics.update();
    spriteGraphics.update();
    textGraphics.update();
    graphics.debugText = format("graphics timings: %s", combinedGraphicsTimer.peek.usecs*0.001);
  }
  
  Entity[] removeEntitiesToBeRemoved()
  {
    auto removedEntities = entities.filter!(entity => entity.toBeRemoved);
    foreach (removedEntity; removedEntities)
      removeEntity(removedEntity);
    entities = entities.filter!(entity => !entity.toBeRemoved).array;
    return removedEntities.array;
  }
}
