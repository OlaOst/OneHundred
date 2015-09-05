module app;

import std.algorithm;
import std.range;
import std.stdio;

import gl3n.linalg;

import camera;
import debugentities;
import entity;
import entityfactory.controllers;
import entityfactory.entities;
import entityfactory.entitycollection;
import entityfactory.tests;
import entityspawns;
import eventhandlers.addremove;
import eventhandlers.debuginfo;
import eventhandlers.editabletext;
import eventhandlers.game;
import eventhandlers.toggleinputwindow;
import graphicscollector;
import playereventhandler;
import renderer.renderer;
import systemset;
import systems.graphics;


void main(string[] args)
{
  ushort listenPort = args.length > 1 ? args[1].to!ushort : 5577;
  int xres = 800;
  int yres = 600;

  auto renderer = new Renderer(xres, yres);
  auto camera = new Camera();
  auto systemSet = new SystemSet(xres, yres, listenPort);

  scope(exit)
  {
    systemSet.close();
    renderer.close();
  }

  Entity[] npcs = createNpcs(0);
  npcs.each!(npc => systemSet.addEntity(npc));

  auto playerSet = "data/playership.txt".createEntityCollectionFromFile;
  
  if (listenPort == 5578)
    playerSet["playership.hull"]["sprite"] = "images/playerShip1_red.png";
  systemSet.addEntityCollection(playerSet);

  Entity inputWindow = null;
  auto mouseCursor = createMouseCursor();
  systemSet.addEntity(mouseCursor);

  //systemSet.addEntity(createMusic());

  auto gameController = createGameController();
  systemSet.addEntity(gameController);

  auto editController = createEditController();
  systemSet.addEntity(editController);

  systemSet.addDebugEntities();

  Entity debugText;
  
  while (!quit)
  {
    systemSet.inputHandler.spawnEntities.each!(spawn => systemSet.addEntity(spawn));
  
    systemSet.update();

    auto gameControllerInput = systemSet.inputHandler.getComponent(gameController);
    gameControllerInput.handleQuit();
    gameControllerInput.handleZoom(camera);
    gameControllerInput.handleAddRemoveEntity(systemSet, npcs);
    gameControllerInput.handleToggleInputWindow(systemSet, inputWindow, mouseCursor);
    gameControllerInput.handleNetworking(systemSet, listenPort);
    gameControllerInput.handleToggleDebugInfo(systemSet, debugText);
    systemSet.inputHandler.getComponent(editController).handleEditableText(inputWindow);
    playerSet["playership.gun"].handlePlayerFireAction(systemSet, npcs);
    camera.position = playerSet["playership"].get!vec3("position");
    mouseCursor["position"] = getWorldPositionFromScreenCoordinates(camera,
                                systemSet.inputHandler.mouseScreenPosition, xres, yres);

    addParticles(systemSet);
    addBullets(npcs, systemSet);
    addNetworkEntities(systemSet);
    
    npcs = npcs.filter!(entity => !entity.get!bool("ToBeRemoved")).array;
    systemSet.removeEntitiesToBeRemoved();

    systemSet.updateDebugEntities();
    systemSet.collectFromGraphicsAndRender(renderer, camera);
  }
}
