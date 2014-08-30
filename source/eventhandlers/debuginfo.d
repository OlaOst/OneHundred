module eventhandlers.debuginfo;

import std.algorithm;
import std.array;

import gl3n.linalg;

import components.input;
import entity;
import entityfactory.tests;
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
      // find out which entities the mouseCursor is overlapping with
      assert(mouseCursor in systemSet.collisionHandler.indexForEntity);
      auto mouseCursorCollider = systemSet.collisionHandler.getComponent(mouseCursor);
      auto mouseCursorOverlaps = mouseCursorCollider.overlappingColliders;
      
      if (mouseCursorOverlaps.empty)
      {
        inputWindow = createText("input: ", vec2(mouseCursor.values["position"].to!(float[2])));
        inputWindow.values["input"] = Input.textInput.to!string; // new Input(Input.textInput);
        systemSet.addEntity(inputWindow);
      }
      else
      {
        auto overlappingCollider = mouseCursorOverlaps.front;
        auto overlappingEntity = systemSet.collisionHandler.getEntity(overlappingCollider);
        inputWindow = createText(overlappingEntity.debugInfo, 
                                 vec2(overlappingEntity.values["position"].to!(float[2])));
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
  if (editableText !is null && "input" in editableText.values)
  {
    //assert(editableText.input !is null);
    
    // TODO: make sure text changes are reflected to relevant components
    if (textInput.actionState["backspace"] == Input.ActionState.Pressed && 
        editableText.values["text"].length > 0)
        editableText.values["text"].popBack();

    editableText.values["text"] ~= editableText.values["editText"];
  }
}

bool toggleDebugInfo = false;
bool toggleInputWindow = false;
