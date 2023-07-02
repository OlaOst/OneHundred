module app;

import std;

import inmath.linalg;

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
import playereventhandler;
import renderer.renderer;
import systems.npchandler;
import systemset;
import textrenderer.textrenderer;


void main(string[] args)
{
  ushort listenPort = args.length > 1 ? args[1].to!ushort : 5577;
  int xres = 1280;
  int yres = 1064;

  auto renderer = new Renderer(xres, yres);
  auto textRenderer = new TextRenderer();
  auto camera = new Camera();
  auto systemSet = new SystemSet(renderer, textRenderer, camera, listenPort);

  scope(exit)
  {
    systemSet.close();
    renderer.close();
  }

  auto npcEntityGroups = "data/npcship.txt".createEntityCollectionFromFile.repeat(0).array;
  npcEntityGroups.each!(npcEntityGroup => systemSet.addEntityCollection(npcEntityGroup));
  //auto npcEntityGroup = "data/npcship.txt".createEntityCollectionFromFile;  
  ///systemSet.addEntityCollection(npcEntityGroup);

  auto playerSet = "data/playership.txt".createEntityCollectionFromFile;

  if (listenPort == 5578)
    playerSet["player.ship.hull"]["graphicsource"] = "images/playerShip1_red.png";
  systemSet.addEntityCollection(playerSet);

  scope(failure)
    playerSet.keys.each!writeln;
  systemSet.npcHandler.setTargetEntity(playerSet["player.ship"]);

  Entity inputWindow = null;
  auto mouseCursor = createMouseCursor();
  systemSet.addEntity(mouseCursor);

  systemSet.addEntity(createStartupSound());
  systemSet.addEntity(createMusic());
  systemSet.addEntityCollection("data/testtext.txt".createEntityCollectionFromFile);

  auto gameController = createGameController();
  systemSet.addEntity(gameController);
  auto editController = createEditController();
  systemSet.addEntity(editController);
  Entity debugText;

  while (!quit)
  {
    systemSet.inputHandler.spawnEntities.each!(spawn => systemSet.addEntity(spawn));
    systemSet.update();

    auto gameControllerInput = systemSet.inputHandler.getComponent(gameController);
    gameControllerInput.handleQuit();
    gameControllerInput.handleZoom(camera);
    gameControllerInput.handleAddRemoveEntity(systemSet, npcEntityGroups);
    gameControllerInput.handleToggleInputWindow(systemSet, inputWindow, mouseCursor);
    gameControllerInput.handleNetworking(systemSet, listenPort);
    gameControllerInput.handleToggleDebugInfo(systemSet, debugText);
    systemSet.inputHandler.getComponent(editController).handleEditableText(inputWindow);
    playerSet["player.ship.gun"].handlePlayerFireAction(systemSet);
    camera.position = playerSet["player.ship"].get!vec3("position");
    mouseCursor["position"] = camera.getWorldPositionFromScreenCoordinates(
      systemSet.inputHandler.mouseScreenPosition, xres, yres);

    addParticles(systemSet);
    addBullets(npcEntityGroups, systemSet);
    addNetworkEntities(systemSet);

    npcEntityGroups = npcEntityGroups.filter!(npcEntityGroup => !npcEntityGroup.values
      .all!(npcEntity => npcEntity.get!bool("ToBeRemoved"))).array;
    systemSet.removeEntitiesToBeRemoved();

    systemSet.updateDebugEntities();

    debug foreach(box; makeSpatialTreeBoxes(systemSet.collisionHandler.boxes))
      systemSet.addEntity(box);
  }
}
