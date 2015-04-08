module systemset;

import std.algorithm;
import std.array;
import std.datetime;
import std.string;

import entity;
import entityhandler;
import systems.collisionhandler;
import systems.inputhandler;
import systems.networkhandler;
import systems.physics;
import systems.polygongraphics;
import systems.relationhandler;
import systems.soundsystem;
import systems.spritegraphics;
import systems.textgraphics;
import systems.timehandler;


class SystemSet
{
  Entity[] entities;
  EntityHandler[] entityHandlers;
  EntityHandler[] graphicsHandlers;
  string graphicsTimingText;
  PolygonGraphics polygonGraphics;
  SpriteGraphics spriteGraphics;
  TextGraphics textGraphics;
  Physics physics;
  InputHandler inputHandler;
  CollisionHandler collisionHandler;
  SoundSystem soundSystem;
  TimeHandler timeHandler;
  RelationHandler relationHandler;
  NetworkHandler networkHandler;

  this(int xres, int yres, ushort listenPort)
  {
    polygonGraphics = new PolygonGraphics(xres, yres);
    spriteGraphics = new SpriteGraphics(xres, yres);
    textGraphics = new TextGraphics(xres, yres);
    physics = new Physics();
    inputHandler = new InputHandler();
    collisionHandler = new CollisionHandler();
    soundSystem = new SoundSystem();
    timeHandler = new TimeHandler();
    relationHandler = new RelationHandler();
    networkHandler = new NetworkHandler(listenPort);
    entityHandlers = cast(EntityHandler[])[/*graphics,*/ physics, soundSystem,
                                           polygonGraphics, spriteGraphics, textGraphics,
                                           inputHandler, collisionHandler,
                                           timeHandler, relationHandler, networkHandler];
    graphicsHandlers = cast(EntityHandler[])[polygonGraphics, spriteGraphics, textGraphics];
  }

  void close()
  {
    textGraphics.close();
    spriteGraphics.close();
    soundSystem.silence();
    networkHandler.connection.close();
  }

  void addEntity(Entity entity)
  {
    foreach (entityHandler; entityHandlers)
      entityHandler.addEntity(entity);
    entities ~= entity;
  }

  void update()
  {
    foreach (entityHandler; entityHandlers.filter!(handler => !graphicsHandlers.canFind(handler)))
      entityHandler.update();
    StopWatch graphicsTimer;
    graphicsTimer.start;
    foreach (graphicsHandler; graphicsHandlers)
      graphicsHandler.update();
    auto graphicsComponentCount = polygonGraphics.components.length +
                                  spriteGraphics.components.length +
                                  textGraphics.components.length;
    graphicsTimingText = format("graphics components: %s\ngraphics timings: %s",
                                graphicsComponentCount,
                                graphicsTimer.peek.usecs*0.001);
  }

  Entity[] removeEntitiesToBeRemoved()
  {
    auto removedEntities = entities.filter!(entity => entity.get!bool("ToBeRemoved"));
    foreach (removedEntity; removedEntities)
      foreach (entityHandler; entityHandlers)
        entityHandler.removeEntity(removedEntity);
    entities = entities.filter!(entity => !entity.get!bool("ToBeRemoved")).array;
    return removedEntities.array;
  }
}
