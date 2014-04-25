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
import systemset;
import timer;


void main()
{
  int xres = 1024;
  int yres = 768;
  
  auto renderer = new Renderer(xres, yres);
  auto timer = new Timer();
  
  auto systemSet = new SystemSet(xres, yres);
  
  scope(exit)
  {
    systemSet.close();
    renderer.close();
  }
  
  Entity[] entities;
  Entity[] npcs = createEntities(100);
  entities ~= npcs;
  
  auto player = createPlayer();
  entities ~= player;
  
  auto mouseCursor = createMouseCursor();
  entities ~= mouseCursor;

  //auto music = createMusic();
  //entities ~= music;
  //auto startupSound = createStartupSound();
  //entities ~= startupSound;
  
  entities ~= createText();
  auto debugText = createDebugText();
  entities ~= debugText;
  
  auto gameController = createGameController();
  entities ~= gameController;
  
  foreach (entity; entities)
    systemSet.addEntity(entity);
  
  bool keepRunning = true;
  timer.start();
  while (keepRunning)
  {
    timer.incrementAccumulator();
    
    systemSet.update(timer);
    
    auto gameActions = gameController.input.isActive;
    if ("zoomIn" in gameActions && gameActions["zoomIn"])
      systemSet.graphics.zoom += systemSet.graphics.zoom * 1.0/60.0;
    if ("zoomOut" in gameActions && gameActions["zoomOut"])
      systemSet.graphics.zoom -= systemSet.graphics.zoom * 1.0/60.0;
    if ("quit" in gameActions && gameActions["quit"])
      keepRunning = false;
    if ("addEntity" in gameActions && gameActions["addEntity"])
    {
      auto entity = createEntities(1)[0];
      systemSet.addEntity(entity);
      npcs ~= entity;
    }
    if ("removeEntity" in gameActions && gameActions["removeEntity"] && npcs.length > 0)
    {
      auto entity = npcs[$-1];      
      systemSet.removeEntity(entity);
      npcs.popBack();
    }

    mouseCursor.vectors["position"] = 
      systemSet.graphics.getWorldPositionFromScreenCoordinates(
      systemSet.inputHandler.mouseScreenPosition);
      
    debugText.text.text = systemSet.collisionHandler.debugText;
      
    renderer.draw(systemSet.graphics.vertices, 
                  systemSet.graphics.colors, 
                  systemSet.graphics.texCoords, 
                  systemSet.graphics.textureSet);
  }
}
