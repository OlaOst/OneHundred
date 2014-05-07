module eventhandler;

import std.algorithm;
import std.array;

import gl3n.linalg;

import components.input;
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
  static int index = 0;
  gameInput.toggleAction("toggleDebugInfo", toggleDebugInfo);
  if (toggleDebugInfo)
  {
    if (debugText is null)
    {
      debugText = createText("??", vec2(-3.0, -2.0));
      systemSet.addEntity(debugText);
    }
    /*else
    {
      systemSet.removeEntity(debugText);
      debugText = null;
    }*/
    
    index++;
  }
  
  switch (index % 3)
  {
    case 0:
      debugText.text.text = systemSet.collisionHandler.debugText;
      break;
    case 1:
      debugText.text.text = systemSet.physics.debugText;
      break;
    case 2:
      debugText.text.text = systemSet.graphics.debugText;
      break;
      
    default:
      debugText.text.text = "?";
  }
}

void handleEditableText(Input textInput, Entity editableText)
{
  assert(editableText.input !is null);
  
  foreach (string key, Input.ActionState pressedAction; textInput.actionState)
  {
    if (pressedAction == Input.ActionState.Pressed)
    {
      if (key == "backspace" && editableText.text.text.length > 0)
        editableText.text.text.popBack();
    }
  }
  
  editableText.text.text ~= editableText.editText;
}

bool quit = false;
bool zoomIn = false;
bool zoomOut = false;
bool addEntity = false;
bool removeEntity = false;
bool toggleDebugInfo = false;
