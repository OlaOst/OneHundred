module eventhandler;

import std.array;

import component.input;
import entity;
import entityfactory.entities;
import entityfactory.tests;
import systems.graphics;
import systemset;


void handleQuit(Input gameInput)
{
  gameInput.setAction("quit", quit);
}

void handleZoom(Input gameInput, Graphics graphics)
{
  gameInput.setAction("zoomIn", zoomIn);
  gameInput.setAction("zoomOut", zoomOut);
  if (zoomIn)
    graphics.zoom += graphics.zoom * 1.0/60.0;
  if (zoomOut)
    graphics.zoom -= graphics.zoom * 1.0/60.0;
}

void handleAddRemoveEntity(Input gameInput, SystemSet systemSet, ref Entity[] npcs)
{
  gameInput.setAction("addEntity", addEntity);
  gameInput.setAction("removeEntity", removeEntity);
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
}

void handleToggleDebugInfo(Input gameInput, SystemSet systemSet, ref Entity debugText)
{
  gameInput.toggleAction("toggleDebugInfo", toggleDebugInfo);
  if (toggleDebugInfo)
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
}

bool quit = false;
bool zoomIn = false;
bool zoomOut = false;
bool addEntity = false;
bool removeEntity = false;
bool toggleDebugInfo = false;
