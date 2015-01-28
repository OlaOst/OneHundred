module systemset;

import std.algorithm;
import std.conv;
import std.datetime;
import std.range;
import std.string;

import entity;
import entityhandler;
import systems.collisionhandler;
import systems.graphics;
import systems.inputhandler;
import systems.networkhandler;
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
  EntityHandler[] graphicsHandlers;
  string graphicsTimingText;
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
  NetworkHandler networkHandler;
  
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
    networkHandler = new NetworkHandler();
    
    entityHandlers = cast(EntityHandler[])[graphics, physics, soundSystem,
                                           polygonGraphics, spriteGraphics, textGraphics, 
                                           inputHandler, collisionHandler,  
                                           timeHandler, relationHandler, networkHandler];
                                           
    graphicsHandlers = cast(EntityHandler[])[polygonGraphics, spriteGraphics, textGraphics];
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
  
  void update()
  {
    foreach (entityHandler; entityHandlers.filter!(handler => !graphicsHandlers.canFind(handler)))
      entityHandler.update();
      
    StopWatch graphicsTimer;
    graphicsTimer.start;
    foreach (graphicsHandler; graphicsHandlers)
      graphicsHandler.update();
    
    auto graphicsComponentCount = polygonGraphics.components.length + spriteGraphics.components.length + textGraphics.components.length;
    graphicsTimingText = format("graphics components: %s\ngraphics timings: %s", graphicsComponentCount, graphicsTimer.peek.usecs*0.001);
  }
  
  Entity[] removeEntitiesToBeRemoved()
  {
    auto removedEntities = entities.filter!(entity => entity.get!bool("ToBeRemoved"));
    foreach (removedEntity; removedEntities)
      removeEntity(removedEntity);
    entities = entities.filter!(entity => !entity.get!bool("ToBeRemoved")).array;
    return removedEntities.array;
  }
  
  void updateDebugEntities()
  {
    foreach (entityHandler; entityHandlers)
    {
      import std.math;
      assert(!entityHandler.debugTiming.isNaN);
      
      auto found = entities.find!(entity => entity.values.get("name", "") == entityHandler.className);
      
      if (!found.empty)
      {
        auto debugEntity = found.front;
        
        auto prevSize = debugEntity.get!double("size");
        auto size = prevSize * 0.9 + (0.3 + sqrt(entityHandler.debugTiming)*0.1) * 0.1;
        
        auto prevTimePerComponent = debugEntity.get!double("timePerComponent");
        auto timePerComponent = prevTimePerComponent * 0.9 + (entityHandler.debugTiming / entityHandler.componentCount) * 0.1;
        debugEntity.values["timePerComponent"] = timePerComponent.to!string;
        
        assert("name" in debugEntity.values, debugEntity.values.to!string);
        assert("size" in debugEntity.values, debugEntity.values.to!string);
        //import std.stdio;
        //writeln("changing debugentity ", debugEntity.values["name"], " size from ", debugEntity.values["size"], " to ", size);
        
        import gl3n.linalg;
        import components.drawables.polygon;
        auto polygon = new Polygon(size, 16, vec4(timePerComponent, 0.67, 0.33, 1.0));
        debugEntity.values["size"] = size.to!string;
        debugEntity.values["polygon.vertices"] = polygon.vertices.to!string;
        debugEntity.values["polygon.colors"] = polygon.colors.to!string;
      }
    }
  }
}
