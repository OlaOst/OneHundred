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
  
  auto graphics = new Graphics(xres, yres);
  auto physics = new Physics();
  auto inputHandler = new InputHandler();
  auto collisionHandler = new CollisionHandler();
  auto soundSystem = new SoundSystem();
  
  scope(exit)
  {
    renderer.close();
    soundSystem.silence();
  }
  
  Entity[] entities;
  Entity[] npcs = createEntities(100);
  entities ~= npcs;
  
  auto player = createPlayer();
  entities ~= player;
  
  auto mouseCursor = createMouseCursor();
  entities ~= mouseCursor;

  auto music = createMusic();
  entities ~= music;
  //auto startupSound = createStartupSound();
  //entities ~= startupSound;
  
  entities ~= createText();
  auto debugText = createDebugText();
  entities ~= debugText;
  
  auto gameController = createGameController();
  entities ~= gameController;
  
  foreach (entity; entities)
  {
    graphics.addEntity(entity);
    physics.addEntity(entity);
    inputHandler.addEntity(entity);
    collisionHandler.addEntity(entity);
    soundSystem.addEntity(entity);
  }
  
  bool keepRunning = true;
  timer.start();
  while (keepRunning)
  {
    timer.incrementAccumulator();
    physics.setTimer(timer);
    
    collisionHandler.update();
    physics.updateFromEntities();
    
    graphics.update();
    physics.update();
    inputHandler.update();
    soundSystem.update();
    
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
    if ("addEntity" in gameActions && gameActions["addEntity"])
    {
      auto entity = createEntities(1)[0];

      graphics.addEntity(entity);
      physics.addEntity(entity);
      inputHandler.addEntity(entity);
      collisionHandler.addEntity(entity);
      soundSystem.addEntity(entity);
      
      npcs ~= entity;
    }
    if ("removeEntity" in gameActions && gameActions["removeEntity"] && npcs.length > 1)
    {
      auto entity = npcs[$-1];
      
      graphics.removeEntity(entity);
      physics.removeEntity(entity);
      inputHandler.removeEntity(entity);
      collisionHandler.removeEntity(entity);
      soundSystem.removeEntity(entity);

      npcs.length = npcs.length - 1;
    }

    mouseCursor.vectors["position"] = 
      graphics.getWorldPositionFromScreenCoordinates(inputHandler.mouseScreenPosition);
      
    debugText.text.text = collisionHandler.debugText;
      
    renderer.draw(graphics.vertices, graphics.colors, graphics.texCoords);
  }
}
