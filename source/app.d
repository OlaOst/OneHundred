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
  
  Entity[] npcs = createEntities(100);
  foreach (npc; npcs)
    systemSet.addEntity(npc);
  
  auto player = createPlayer();  
  systemSet.addEntity(player);
  
  auto mouseCursor = createMouseCursor();
  systemSet.addEntity(mouseCursor);

  auto music = createMusic();
  systemSet.addEntity(music);
  
  //auto startupSound = createStartupSound();
  //systemSet.addEntity(startupSound);  
  
  auto debugText = createDebugText();
  systemSet.addEntity(debugText);
  
  auto gameController = createGameController();
  systemSet.addEntity(gameController);
  
  bool keepRunning = true;
  bool zoomIn = false;
  bool zoomOut = false;
  bool addEntity = false;
  bool removeEntity = false;
  bool fire = false;
  timer.start();
  while (keepRunning)
  {
    timer.incrementAccumulator();
    
    systemSet.update(timer);
    
    auto gameInput = gameController.input;
    
    gameInput.setAction("zoomIn", zoomIn);
    gameInput.setAction("zoomOut", zoomOut);
    gameInput.setAction("addEntity", addEntity);
    gameInput.setAction("removeEntity", removeEntity);
    gameInput.setAction("quit", keepRunning);
    player.input.setAction("fire", fire);
    if (zoomIn)
      systemSet.graphics.zoom += systemSet.graphics.zoom * 1.0/60.0;
    if (zoomOut)
      systemSet.graphics.zoom -= systemSet.graphics.zoom * 1.0/60.0;
    
    if (addEntity)
    {
      auto entity = createEntities(1)[0];
      systemSet.addEntity(entity);
      npcs ~= entity;
    }
    
    if (removeEntity && npcs.length > 0)
    {
      auto entity = npcs[$-1];
      systemSet.removeEntity(entity);
      npcs.popBack();
    }
    
    if (gameInput.getActionState("toggleDebugInfo") == Input.ActionState.Released)
    {
      if (debugText is null)
      {
        debugText = createDebugText();
        systemSet.addEntity(debugText);
      }
      else
      {
        systemSet.removeEntity(debugText);
        debugText = null;
      }
    }
    
    static float reloadTimeLeft = 0.0;
    if (fire && reloadTimeLeft <= 0.0)
    {
      auto bullet = createBullet(player.vectors["position"], player.scalars["angle"], player.vectors["velocity"]);
      systemSet.addEntity(bullet);
      npcs ~= bullet;
      reloadTimeLeft = 0.1;
    }
    else if (reloadTimeLeft > 0.0)
    {
      reloadTimeLeft -= timer.frameTime;
    }

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
