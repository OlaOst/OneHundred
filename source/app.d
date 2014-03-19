import std.algorithm;
import std.math;
import std.random;
import std.range;
import std.stdio;

import artemisd.all;
import gl3n.linalg;

import component.input;
import entityfactory.entities;
import entityfactory.tests;
import renderer;
import system.collisionhandler;
import system.graphics;
import system.inputhandler;
import system.movement;
import system.physics;
import system.soundsystem;
import timer;


void main()
{
  int xres = 1024;
  int yres = 768;
  auto renderer = new Renderer(xres, yres);
  
  auto timer = new Timer();
  auto world = new World();
  auto graphics = new Graphics(xres, yres);
  auto physics = new Physics();
  auto inputHandler = new InputHandler();
  auto collisionHandler = new CollisionHandler(world);
  auto soundSystem = new SoundSystem();
  world.setSystem(graphics);
  world.setSystem(physics);
  world.setSystem(inputHandler);
  world.setSystem(collisionHandler);
  world.setSystem(soundSystem);
  world.initialize();
  
  auto gameController = createGameController(world);
  gameController.addToWorld();
  
  Entity[] entities = createEntities(world, 1);
  entities ~= createPlayer(world);
  auto mouseCursor = createMouseCursor(world);
  entities ~= mouseCursor;
  //entities ~= createMusic(world);
  //entities ~= createStartupSound(world);
  entities ~= createText(world);
  
  foreach (entity; entities)
    entity.addToWorld();
  
  bool keepRunning = true;
  timer.start();
  while (keepRunning)
  {
    timer.incrementAccumulator();
    physics.update(timer);
    collisionHandler.update();
    
    //world.setDelta(1.0/60.0);
    world.process();
    
    inputHandler.update();
    auto gameActions = gameController.getComponent!Input.isActive;
    if ("zoomIn" in gameActions && gameActions["zoomIn"])
      graphics.zoom += graphics.zoom * 1.0/60.0;
    if ("zoomOut" in gameActions && gameActions["zoomOut"])
      graphics.zoom -= graphics.zoom * 1.0/60.0;
    if ("quit" in gameActions && gameActions["quit"])
      keepRunning = false;
      
    import component.position;
    mouseCursor.getComponent!Position.position = graphics.getWorldPositionFromScreenCoordinates(inputHandler.mouseScreenPosition);
      
    renderer.draw(graphics.getVertices(), graphics.getColors(), graphics.getTexCoords());
    graphics.clear();
  }
  
  scope(exit)
  {
    renderer.close();
    soundSystem.silence();
    
    foreach (entity; entities)
      soundSystem.silence(entity);
  }
}
