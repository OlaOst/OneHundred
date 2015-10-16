module systemset;

import std.algorithm;
import std.array;
import std.datetime;
import std.string;

import entity;
import entityhandler;
import systems.accumulatorhandler;
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
  AccumulatorHandler accumulatorHandler;
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
    accumulatorHandler = new AccumulatorHandler();
    networkHandler = new NetworkHandler(listenPort);
    entityHandlers = cast(EntityHandler[])[/*graphics,*/ physics, soundSystem,
                                           polygonGraphics, spriteGraphics, textGraphics,
                                           inputHandler, collisionHandler, timeHandler, 
                                           relationHandler, accumulatorHandler, networkHandler];
    graphicsHandlers = cast(EntityHandler[])[polygonGraphics, spriteGraphics, textGraphics];
  }

  void close()
  {
    entityHandlers.each!(entity => entity.close());
  }

  void addEntity(Entity entity)
  {
    entityHandlers.each!(handler => handler.tweakEntity(entity));
    entityHandlers.each!(handler => handler.addEntity(entity));
    entities ~= entity;
  }
  
  void addEntityCollection(Entity[string] entityCollection)
  {
    // add entities in correct order, entities depending on other should be added later
    // dependent entities always have a longer key since the dependency is part of the key
    entityCollection.byKey.array.sort!((left, right) => left.length < right.length)
                                .map!(key => entityCollection[key])
                                .each!(entity => addEntity(entity));
  }

  void update()
  {
    entityHandlers.filter!(handler => !graphicsHandlers.canFind(handler)).each!(e => e.update());
    auto graphicsTimer = StopWatch(AutoStart.yes);
    graphicsHandlers.each!(handler => handler.update());
    auto graphicsComponentCount = graphicsHandlers.map!(graphics => graphics.componentCount).sum;
    graphicsTimingText = format("graphics components: %s\ngraphics timings: %s",
                                graphicsComponentCount, graphicsTimer.peek.usecs*0.001);
  }

  Entity[] removeEntitiesToBeRemoved()
  {
    auto removedEntities = entities.filter!(entity => entity.get!bool("ToBeRemoved"));
    cartesianProduct(entityHandlers, removedEntities).each!(tup => tup[0].removeEntity(tup[1]));
    entities = entities.filter!(entity => !entity.get!bool("ToBeRemoved")).array;
    return removedEntities.array;
  }
}
