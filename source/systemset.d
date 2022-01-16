module systemset;

import std;

import bindbc.opengl;

import onehundred;


class SystemSet
{
  Entity[] entities;
  EntityHandler[] entityHandlers;
  Renderer renderer;
  
  Text text;
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

    this.renderer = renderer;

    textures["polygon"] = new Texture2D();
    textures["polygon"].set_data([0, 0, 0, 0], GL_RGBA, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE);

    textures["text"] = textRenderer.atlas;

    text = new Text(textRenderer, camera, textRenderer.atlas);
    graphics = new Graphics(camera, textures);
    physics = new Physics();
    inputHandler = new InputHandler();
    collisionHandler = new CollisionHandler();
    soundSystem = new SoundSystem();
    timeHandler = new TimeHandler();
    relationHandler = new RelationHandler();
    accumulatorHandler = new AccumulatorHandler();
    networkHandler = new NetworkHandler(listenPort);
    entityHandlers = cast(EntityHandler[])[text, graphics, physics, soundSystem,
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
    renderer.toScreen();
  }

  Entity[] removeEntitiesToBeRemoved()
  {
    auto removedEntities = entities.filter!(entity => entity.get!bool("ToBeRemoved"));
    cartesianProduct(entityHandlers, removedEntities).each!(tup => tup[0].removeEntity(tup[1]));
    entities = entities.filter!(entity => !entity.get!bool("ToBeRemoved")).array;
    return removedEntities.array;
  }
}
