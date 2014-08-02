import std.algorithm;
import std.random;
import std.range;
import std.stdio;

import gl3n.linalg;

import components.input;
import entity;
import entityfactory.entities;
import entityfactory.tests;
import entityspawns;
import eventhandlers.addremove;
import eventhandlers.debuginfo;
import eventhandlers.game;
import playereventhandler;
import renderer;
import systemset;
import timer;


void main()
{
  int xres = 1024;
  int yres = 768;
  
  auto renderer = new Renderer(xres, yres);
  auto systemSet = new SystemSet(xres, yres);
  auto timer = new Timer();
  
  scope(exit)
  {
    systemSet.close();
    renderer.close();
  }
  
  Entity[] particles;
  Entity[] npcs = createEntities(1);
  foreach (npc; npcs)
    systemSet.addEntity(npc);
  
  auto player = createPlayer();
  systemSet.addEntity(player);
  
  Entity inputWindow = null;
  auto mouseCursor = createMouseCursor();
  systemSet.addEntity(mouseCursor);

  //auto music = createMusic();
  //systemSet.addEntity(music);
  
  auto debugText = createText("??", vec2(-3.0, -2.0));
  systemSet.addEntity(debugText);
  
  auto editableText = createText("", vec2(-3.0, 2.0));
  editableText.input = new Input(Input.textInput);
  systemSet.addEntity(editableText);
  
  auto gameController = createGameController();
  systemSet.addEntity(gameController);
  
  auto editController = createEditController();
  systemSet.addEntity(editController);
  
  timer.start();
  while (!quit)
  {
    timer.incrementAccumulator();
    
    systemSet.update(timer);
    
    gameController.input.handleQuit();
    gameController.input.handleZoom(systemSet.graphics);
    gameController.input.handleAddRemoveEntity(systemSet, npcs);
    gameController.input.handleToggleDebugInfo(systemSet, debugText);
    gameController.input.handleToggleInputWindow(systemSet, inputWindow, mouseCursor);
    editController.input.handleEditableText(editableText);
    player.handlePlayerFireAction(systemSet, npcs, timer);
    
    addParticles(particles, systemSet);
    addBullets(npcs, systemSet);
    
    auto entitiesToRemove = npcs.filter!(entity => entity.toBeRemoved)
                                .chain(particles.filter!(entity => entity.toBeRemoved));
    foreach (entityToRemove; entitiesToRemove)
      systemSet.removeEntity(entityToRemove);
    npcs = npcs.filter!(entity => !entity.toBeRemoved).array;
    particles = particles.filter!(entity => !entity.toBeRemoved).array;
    
    mouseCursor.vectors["position"] = 
      systemSet.graphics.getWorldPositionFromScreenCoordinates(
      systemSet.inputHandler.mouseScreenPosition);
      
    renderer.draw(systemSet.graphics.vertices, 
                  systemSet.graphics.colors, 
                  systemSet.graphics.texCoords, 
                  systemSet.graphics.textureSet);
  }
}
