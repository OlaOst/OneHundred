import std.algorithm;
import std.random;
import std.range;
import std.stdio;

import gl3n.linalg;

import component.input;
import entity;
import entityfactory.entities;
import entityfactory.tests;
import renderer;
import system;
import systems.collisionhandler;
import systems.graphics;
import systems.inputhandler;
import systems.physics;
import systems.soundsystem;
import timer;


void main()
{
  int xres = 1024;
  int yres = 768;
  
  auto renderer = new Renderer(xres, yres);
  auto timer = new Timer(); 
  
  System[] systems;
  
  auto graphics = new Graphics(xres, yres);
  auto physics = new Physics();
  auto inputHandler = new InputHandler();
  auto collisionHandler = new CollisionHandler();
  auto soundSystem = new SoundSystem();
  
  systems ~= graphics;
  systems ~= physics;
  systems ~= inputHandler;
  systems ~= collisionHandler;
  systems ~= soundSystem;
  
  scope(exit)
  {
    renderer.close();
    soundSystem.silence();
  }
  
  Entity[] entities = createEntities(10);
  entities ~= createPlayer();
  
  auto mouseCursor = createMouseCursor();
  entities ~= mouseCursor;

  //entities ~= createMusic();
  entities ~= createStartupSound();
  
  entities ~= createText();
  
  auto gameController = createGameController();
  inputHandler.addEntity(gameController);
  
  foreach (system; systems)
    foreach (entity; entities)
      system.addEntity(entity);
  
  bool keepRunning = true;
  timer.start();
  while (keepRunning)
  {
    timer.incrementAccumulator();
    physics.setTimer(timer);
    
    foreach (system; systems)
      system.update();
    
    physics.updateEntities();
    graphics.updateFromEntities();
    collisionHandler.updateFromEntities();
    
    auto gameActions = gameController.input.isActive;
    //writeln("gameactions: ", gameActions);
    if ("zoomIn" in gameActions && gameActions["zoomIn"])
      graphics.zoom += graphics.zoom * 1.0/60.0;
    if ("zoomOut" in gameActions && gameActions["zoomOut"])
      graphics.zoom -= graphics.zoom * 1.0/60.0;
    if ("quit" in gameActions && gameActions["quit"])
      keepRunning = false;

    mouseCursor.vectors["position"] = 
      graphics.getWorldPositionFromScreenCoordinates(inputHandler.mouseScreenPosition);
      
    renderer.draw(graphics.vertices, graphics.colors, graphics.texCoords);
  }
}
