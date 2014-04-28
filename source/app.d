import std.algorithm;
import std.random;
import std.range;
import std.stdio;

import gl3n.linalg;

import component.input;
import entity;
import entityfactory.entities;
import entityfactory.tests;
import eventhandler;
import playereventhandler;
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
  
  Entity[] npcs = createEntities(100);
  foreach (npc; npcs)
    systemSet.addEntity(npc);
  
  auto player = createPlayer();  
  systemSet.addEntity(player);
  
  auto mouseCursor = createMouseCursor();
  systemSet.addEntity(mouseCursor);

  auto music = createMusic();
  //systemSet.addEntity(music);
  
  //auto startupSound = createStartupSound();
  //systemSet.addEntity(startupSound);  
  
  auto debugText = createDebugText();
  systemSet.addEntity(debugText);
  
  auto gameController = createGameController();
  systemSet.addEntity(gameController);
  
  timer.start();
  while (!quit)
  {
    timer.incrementAccumulator();
    
    systemSet.update(timer);
    
    gameController.input.handleQuit();
    gameController.input.handleZoom(systemSet.graphics);
    gameController.input.handleAddRemoveEntity(systemSet, npcs);
    gameController.input.handleToggleDebugInfo(systemSet, debugText);
    player.handlePlayerFireAction(systemSet, npcs, timer);

    mouseCursor.vectors["position"] = 
      systemSet.graphics.getWorldPositionFromScreenCoordinates(
      systemSet.inputHandler.mouseScreenPosition);
      
    if (debugText)
      debugText.text.text = systemSet.collisionHandler.debugText;
      
    renderer.draw(systemSet.graphics.vertices, 
                  systemSet.graphics.colors, 
                  systemSet.graphics.texCoords, 
                  systemSet.graphics.textureSet);
  }
}
