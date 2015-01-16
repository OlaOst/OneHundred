import std.algorithm;
import std.random;
import std.range;
import std.stdio;

import gl3n.linalg;

import components.input;
import entity;
import entityfactory.controllers;
import entityfactory.entities;
import entityfactory.tests;
import entityspawns;
import eventhandlers.addremove;
import eventhandlers.debuginfo;
import eventhandlers.editabletext;
import eventhandlers.game;
import eventhandlers.toggleinputwindow;
import graphicscollector;
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
  Entity[] npcs = createNpcs(1);
  foreach (npc; npcs)
    systemSet.addEntity(npc);
  
  auto player = "data/player.txt".createEntityFromFile;
  systemSet.addEntity(player);
  
  Entity inputWindow = null;
  auto mouseCursor = createMouseCursor();
  systemSet.addEntity(mouseCursor);

  auto music = createMusic();
  //systemSet.addEntity(music);
  
  auto debugText = createText("??", vec2(-3.0, -2.0));
  //systemSet.addEntity(debugText);
  
  auto gameController = createGameController();
  systemSet.addEntity(gameController);
  
  auto editController = createEditController();
  systemSet.addEntity(editController);
  
  systemSet.addDebugEntities();
  
  timer.start();
  while (!quit)
  {
    timer.incrementAccumulator();
    
    systemSet.update(timer);
    
    auto gameControllerInput = systemSet.inputHandler.getComponent(gameController);
    auto editControllerInput = systemSet.inputHandler.getComponent(editController);
    gameControllerInput.handleQuit();
    gameControllerInput.handleZoom(systemSet.graphics.camera);
    gameControllerInput.handleAddRemoveEntity(systemSet, npcs);
    gameControllerInput.handleToggleDebugInfo(systemSet, debugText);
    gameControllerInput.handleToggleInputWindow(systemSet, inputWindow, mouseCursor);
    editControllerInput.handleEditableText(inputWindow);
    player.handlePlayerFireAction(systemSet, npcs, timer);
    
    addParticles(particles, systemSet);
    addBullets(npcs, systemSet);
    
    npcs = npcs.filter!(entity => !entity.get!bool("ToBeRemoved")).array;
    particles = particles.filter!(entity => !entity.get!bool("ToBeRemoved")).array;
    systemSet.removeEntitiesToBeRemoved();
    
    mouseCursor.values["position"] = 
      systemSet.graphics.getWorldPositionFromScreenCoordinates(
      systemSet.inputHandler.mouseScreenPosition).to!string;
    // TODO: remember to update position of mousecursor components in systems
    
    systemSet.updateDebugEntities();
    systemSet.collectFromGraphicsAndRender(renderer);
  }
}
