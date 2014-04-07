import std.algorithm;
import std.math;
import std.random;
import std.range;
import std.stdio;

import gl3n.linalg;

import component.input;
import entity;
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
  // TODO: get rid of artemisd, make replacement
  int xres = 1024;
  int yres = 768;
  auto renderer = new Renderer(xres, yres);
  
  auto timer = new Timer();
  
  //auto movement = new Movement();
  
  auto graphics = new Graphics(xres, yres);
  auto physics = new Physics();
  auto inputHandler = new InputHandler();
  auto collisionHandler = new CollisionHandler();
  auto soundSystem = new SoundSystem();
  
  scope(exit)
  {
    renderer.close();
    soundSystem.silence();
    
    foreach (entity; entities)
      soundSystem.silence(entity);
  }
  
  Entity[] entities = createEntities(1);
  entities ~= createPlayer();
  
  auto mouseCursor = createMouseCursor();
  entities ~= mouseCursor;

  entities ~= createMusic();
  //entities ~= createStartupSound();
  
  entities ~= createText();
  
  auto gameController = createGameController();
  inputHandler.addEntity(gameController);
  
  foreach (entity; entities)
  {
    physics.addEntity(entity);
    graphics.addEntity(entity);
    collisionHandler.addEntity(entity);
    inputHandler.addEntity(entity);
    soundSystem.addEntity(entity);
  }
  
  bool keepRunning = true;
  timer.start();
  while (keepRunning)
  {
    timer.incrementAccumulator();
    physics.setTimer(timer);
    physics.update();
    
    physics.updateEntities();
    graphics.updateFromEntities();
    collisionHandler.updateFromEntities();
    
    graphics.update();
    collisionHandler.update();
    soundSystem.update();
    inputHandler.update();
    
    auto gameActions = gameController.input.isActive;
    //writeln("gameactions: ", gameActions);
    if ("zoomIn" in gameActions && gameActions["zoomIn"])
      graphics.zoom += graphics.zoom * 1.0/60.0;
    if ("zoomOut" in gameActions && gameActions["zoomOut"])
      graphics.zoom -= graphics.zoom * 1.0/60.0;
    if ("quit" in gameActions && gameActions["quit"])
      keepRunning = false;

    mouseCursor.vectors["position"] = graphics.getWorldPositionFromScreenCoordinates(inputHandler.mouseScreenPosition);
    
    //foreach (entity; entities)
      //soundSystem.checkEntity(entity);
      //soundSystem.cleanupEntities();
      
    renderer.draw(graphics.getVertices(), graphics.getColors(), graphics.getTexCoords());
    graphics.clear();
  }
}
