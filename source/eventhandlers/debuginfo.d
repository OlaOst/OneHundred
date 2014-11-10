module eventhandlers.debuginfo;

import std.algorithm;
import std.array;

import gl3n.linalg;

import components.input;
import converters;
import entity;
import entityfactory.tests;
import systemset;


void handleToggleDebugInfo(Input gameInput, SystemSet systemSet, ref Entity debugText)
{
  static int index = 0;
  if (gameInput.isActionToggled("toggleDebugInfo"))
  {
    if (debugText is null)
    {
      debugText = createText("??", vec2(-3.0, -2.0));
      systemSet.addEntity(debugText);
    }
    index++;
  }
  
  // TODO: ensure entity values get reflected to the relevant components
  final switch (index % 3)
  {
    case 0:
      debugText.values["text"] = systemSet.collisionHandler.debugText;
      break;
    case 1:
      debugText.values["text"] = systemSet.physics.debugText;
      break;
    case 2:
      debugText.values["text"] = systemSet.graphics.debugText;
      break;
  }
  
  assert(debugText.values["text"] !is null);
}

void handleToggleInputWindow(Input gameInput, 
                             SystemSet systemSet, 
                             ref Entity inputWindow, 
                             Entity mouseCursor)
{
  if (gameInput.isActionToggled("toggleInputWindow"))
  {
    if (inputWindow is null)
    {
      // find out which entities the mouseCursor is overlapping with
      assert(mouseCursor in systemSet.collisionHandler.indexForEntity);
      auto mouseCursorCollider = systemSet.collisionHandler.getComponent(mouseCursor);
      auto mouseCursorOverlaps = mouseCursorCollider.overlappingColliders;
      
      if (mouseCursorOverlaps.empty)
      {
        inputWindow = createText("input: ", mouseCursor.values["position"].myTo!vec2);
        inputWindow.values["inputType"] = "textInput";
        systemSet.addEntity(inputWindow);
      }
      else
      {
        auto overlappingCollider = mouseCursorOverlaps.front;
        auto overlappingEntity = systemSet.collisionHandler.getEntity(overlappingCollider);
        inputWindow = createText(overlappingEntity.debugInfo, 
                                 overlappingEntity.values["position"].myTo!vec2);
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
    inputWindow.values["position"] = mouseCursor.values["position"];
  }
}

void handleEditableText(Input textInput, Entity editableText)
{
  if (editableText !is null && 
      "inputType" in editableText.values && editableText.values["inputType"] == "textInput")
  {
    // TODO: make sure text changes are reflected to relevant components
    if (textInput.actionState["backspace"] == Input.ActionState.Pressed && 
        editableText.values["text"].length > 0)
        editableText.values["text"].popBack();
    
    if ("editText" in editableText.values)
      editableText.values["text"] ~= editableText.values["editText"];
  }
}
