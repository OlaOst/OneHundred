module systemset;

import std.algorithm;
import std.array;
import std.datetime;
import std.string;

import derelict.opengl3.gl3;

import camera;
import entity;
import entityhandler;
import renderer.renderer;
import systems.accumulatorhandler;
import systems.collisionhandler;
import systems.inputhandler;
import systems.networkhandler;
import systems.physics;
import systems.relationhandler;
import systems.soundsystem;
import systems.timehandler;
import systems.graphics;
import textrenderer.textrenderer;


class SystemSet
{
  Entity[] entities;
  EntityHandler[] entityHandlers;
  Graphics graphics;
  Physics physics;
  InputHandler inputHandler;
  CollisionHandler collisionHandler;
  SoundSystem soundSystem;
  TimeHandler timeHandler;
  RelationHandler relationHandler;
  AccumulatorHandler accumulatorHandler;
  NetworkHandler networkHandler;

  this(Renderer renderer, TextRenderer textRenderer, Camera camera, ushort listenPort)
  {
    import glamour.texture;
    Texture2D[string] textures;

    textures["polygon"] = new Texture2D();
    textures["polygon"].set_data([0, 0, 0, 0], GL_RGBA, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE);

    textures["textoutline"] = new Texture2D();
    textures["textoutline"].set_data([0, 0, 0, 0], GL_RGBA, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE);


    textures["text"] = textRenderer.atlas;

    graphics = new Graphics(renderer, textRenderer, camera, textures);
    physics = new Physics();
    inputHandler = new InputHandler();
    collisionHandler = new CollisionHandler();
    soundSystem = new SoundSystem();
    timeHandler = new TimeHandler();
    relationHandler = new RelationHandler();
    accumulatorHandler = new AccumulatorHandler();
    networkHandler = new NetworkHandler(listenPort);
    entityHandlers = cast(EntityHandler[])[graphics, physics, soundSystem,
                                           inputHandler, collisionHandler, timeHandler,
                                           relationHandler, accumulatorHandler, networkHandler];
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
    entityHandlers.each!(e => e.update());
  }

  Entity[] removeEntitiesToBeRemoved()
  {
    auto removedEntities = entities.filter!(entity => entity.get!bool("ToBeRemoved"));
    cartesianProduct(entityHandlers, removedEntities).each!(tup => tup[0].removeEntity(tup[1]));
    entities = entities.filter!(entity => !entity.get!bool("ToBeRemoved")).array;
    return removedEntities.array;
  }
}
