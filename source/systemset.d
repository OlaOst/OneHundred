module systemset;

import std.algorithm;
import std.datetime;
import std.range;
import std.string;

import entity;
import entityhandler;
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
  EntityHandler[] entityHandlers;
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
    
    entityHandlers = cast(EntityHandler[])[graphics, physics, soundSystem,
                                           polygonGraphics, spriteGraphics, textGraphics, 
                                           inputHandler, collisionHandler,  
                                           timeHandler, relationHandler];
  }
  
  void close()
  {
    textGraphics.textRenderer.close();
    soundSystem.silence();
  }
  
  void addEntity(Entity entity)
  {
    foreach (entityHandler; entityHandlers)
      entityHandler.addEntity(entity);
    
    entities ~= entity;
  }
  
  private void removeEntity(Entity entity)
  {
    foreach (entityHandler; entityHandlers)
      entityHandler.removeEntity(entity);
  }
  
  void update(Timer timer)
  {
    physics.setTimer(timer);
    timeHandler.setTimer(timer);

    foreach (entityHandler; entityHandlers)
      entityHandler.update();
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
