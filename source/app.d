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

    // npc movement
    foreach (npcEntityGroup; npcEntityGroups)
    {
      foreach (npcEngineEntity; npcEntityGroup.values.filter!(npcEntity => 
                                npcEntity.get!string("fullName") == "npc.ship.engine"))
      {
        auto engineForce = npcEngineEntity.has("engineForce") ? npcEngineEntity.get!double("engineForce") : 1.0;
        auto engineTorque = npcEngineEntity.has("engineTorque") ? npcEngineEntity.get!double("engineTorque") : 1.0;
        
        auto angle = npcEngineEntity.get!double("angle");
        
        auto torque = npcEngineEntity.get!double("torque");
        
        // points towrd angle 0 (up or left?)
        
        auto position = npcEngineEntity.get!vec3("position");
        
        auto angleFromCenter = atan2(position.y, position.x);
        auto positionRelativeToPlayer = position - playerSet["player.ship"].get!vec3("position");
        auto angleFromPlayer = atan2(positionRelativeToPlayer.y, positionRelativeToPlayer.x);
        
        //auto angleDiff = (angle - angleFromCenter);
        auto angleDiff = (angle - angleFromPlayer);
        //auto angleDiff = (angleFromPlayer - angle);
        if (angleDiff > PI)
          angleDiff -= PI*2;
        else if (angleDiff < -PI)
          angleDiff += PI*2;
        
        //if ((angleDiff < 0.1 && angleDiff > -0.1) || (angleDiff < (-PI * 0.9) && angleDiff > (PI * 0.9)))
        if (angleDiff.abs < 0.1 || angleDiff.abs > PI*0.9)
        {
          debug writeln("slowing turn");
          // dampen rotation when there is no rotation torque
          torque -= npcEngineEntity.get!double("rotation") * engineTorque;
        }
        //if (angleDiff < (-PI * 0.1))// || angleDiff > (PI * 0.9))
        else if (angleDiff < 0)
        //if (angleDiff < -3)
        {
          debug writeln("turning right");
          torque += engineTorque;
        }
        //else if (angleDiff > (PI * 0.1))// || angleDiff < (-PI * 0.9))
        else if (angleDiff > 0)
        //else if (angleDiff > 3)
        {
          debug writeln("turning left");
          torque -= engineTorque;
        }
        else
        {
          debug writeln("wtf");
          // dampen rotation when there is no rotation torque
          //torque -= npcEngineEntity.get!double("rotation") * engineTorque;
        }
        
        debug writeln("npc angle ", angle, ", position relative to player ", positionRelativeToPlayer, ", angle from center ", angleFromCenter, ", angleDiff ", angleDiff, " engine torque ", engineTorque, " final torque ", torque);
        
        npcEngineEntity["torque"] = torque;
      }
    }

    npcEntityGroups = npcEntityGroups.filter!(npcEntityGroup => !npcEntityGroup.values
      .all!(npcEntity => npcEntity.get!bool("ToBeRemoved"))).array;
    systemSet.removeEntitiesToBeRemoved();

    systemSet.updateDebugEntities();

    debug foreach(box; makeSpatialTreeBoxes(systemSet.collisionHandler.boxes))
      systemSet.addEntity(box);
  }
}
