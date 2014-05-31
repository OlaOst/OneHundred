import std.algorithm;
import std.random;
import std.range;
import std.stdio;

import gl3n.linalg;

import components.input;
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
  auto systemSet = new SystemSet(xres, yres);
  auto timer = new Timer();
  
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

  //auto music = createMusic();
  //systemSet.addEntity(music);
  
  //auto startupSound = createStartupSound();
  //systemSet.addEntity(startupSound);  
  
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
    editController.input.handleEditableText(editableText);
    player.handlePlayerFireAction(systemSet, npcs, timer);
    
    // particle effects
    // TODO: make particles array, they do not belong in npcs array
    npcs ~= systemSet.collisionHandler.collisionEffectParticles;
    foreach (collisionEffectParticle; systemSet.collisionHandler.collisionEffectParticles)
      systemSet.addEntity(collisionEffectParticle);
    systemSet.collisionHandler.collisionEffectParticles.length = 0;
    
    auto entitiesToRemove = npcs.filter!(entity => entity.toBeRemoved);
    foreach (entityToRemove; entitiesToRemove)
      systemSet.removeEntity(entityToRemove);
    npcs = npcs.filter!(entity => !entity.toBeRemoved).array;
    
    mouseCursor.vectors["position"] = 
      systemSet.graphics.getWorldPositionFromScreenCoordinates(
      systemSet.inputHandler.mouseScreenPosition);
      
    renderer.draw(systemSet.graphics.vertices, 
                  systemSet.graphics.colors, 
                  systemSet.graphics.texCoords, 
                  systemSet.graphics.textureSet);
                  
    // npc firing randomly
    import components.collider;
    Entity[] npcBullets;
    //auto actualNpcs = ;
    foreach (npc; npcs.filter!(npc => npc.collider !is null && npc.collider.type == ColliderType.Npc))
    {
      if (uniform(1, 180) == 1)
      {
        assert("position" in npc.vectors);
        assert("velocity" in npc.vectors);
        assert("angle" in npc.scalars);
        auto bullet = createBullet(npc.vectors["position"], 
                                   npc.scalars["angle"], 
                                   npc.vectors["velocity"],
                                   5.0);
        bullet.collider.spawner = npc;
        assert(bullet !is null);
        npcBullets ~= bullet;
      }
    }
    foreach (bullet; npcBullets)
    {
      systemSet.addEntity(bullet);
      npcs ~= bullet;
    }
    npcBullets.length = 0;
  }
}
