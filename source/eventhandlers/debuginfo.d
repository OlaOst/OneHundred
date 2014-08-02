module eventhandlers.debuginfo;

import std.algorithm;
import std.array;

import gl3n.linalg;

import components.input;
import entity;
import entityfactory.tests;
import systems.graphics;
import systemset;


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
    index++;
  }
  
  final switch (index % 3)
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
  }
}

void handleToggleInputWindow(Input gameInput, 
                             SystemSet systemSet, 
                             ref Entity inputWindow, 
                             Entity mouseCursor)
{
  gameInput.toggleAction("toggleInputWindow", toggleInputWindow);
  
  if (toggleInputWindow)
  {
    if (inputWindow is null)
    {
      // find out what entity the mouseCursor is overlapping
      
      assert(mouseCursor in systemSet.collisionHandler.indexForEntity);
      auto mouseCursorCollider = systemSet.collisionHandler.getComponent(mouseCursor);
      auto mouseCursorOverlaps = mouseCursorCollider.overlappingEntities;
      
      if (!mouseCursorOverlaps.empty)
      {
        auto overlappingEntity = mouseCursorOverlaps.front;
        inputWindow = createText(overlappingEntity.entity.debugInfo, 
                                 overlappingEntity.vectors["position"]);
        systemSet.addEntity(inputWindow);
      }
    }
    else
    {
      systemSet.removeEntity(inputWindow);
      inputWindow = null;
    }
  }
  else if (inputWindow !is null)
  {
    inputWindow.vectors["position"] = mouseCursor.vectors["position"];
  }
}

void handleEditableText(Input textInput, Entity editableText)
{
  assert(editableText.input !is null);
  foreach (string key, Input.ActionState pressedAction; textInput.actionState)
  {
    if (pressedAction == Input.ActionState.Pressed && key == "backspace" && 
        editableText.text.text.length > 0)
        editableText.text.text.popBack();
  }
  editableText.text.text ~= editableText.editText;
}

bool toggleDebugInfo = false;
bool toggleInputWindow = false;
