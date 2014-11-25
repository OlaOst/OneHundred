module eventhandlers.debuginfo;

import std.algorithm;
import std.array;

import gl3n.linalg;

import components.collider;
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
  // find out which entities the mouseCursor is overlapping with
  assert(mouseCursor in systemSet.collisionHandler.indexForEntity);
  auto mouseCursorCollider = systemSet.collisionHandler.getComponent(mouseCursor);
  auto mouseCursorOverlaps = mouseCursorCollider.overlappingColliders;
  auto overlappingTexts = mouseCursorOverlaps.filter!(overlap => systemSet.collisionHandler.getComponent(overlap).type == ColliderType.GuiElement);
      
  // left click - focus clicked input window to make it editable
  if (gameInput.isActionToggled("focusInputWindow"))
  {
    if (!overlappingTexts.empty) 
    {
      if (inputWindow == overlappingTexts.front)
        overlappingTexts.popFront();
      if (!overlappingTexts.empty)
        inputWindow = overlappingTexts.front;
    }
    
    // defocus current window
    if (overlappingTexts.empty)
      inputWindow = null;
  }
  
  // right click - toggle input window - close input windows if right clicked, open input window for overlapping entity
  // open new input window if no overlaps
  if (gameInput.isActionToggled("toggleInputWindow"))
  {
    if (!overlappingTexts.empty)
    {
      // remove the last text window added
      auto lastOne = overlappingTexts.front;
      
      while (!overlappingTexts.empty)
      {
        lastOne = overlappingTexts.front;
        overlappingTexts.popFront();
      }
      assert(lastOne !is null);
      systemSet.removeEntity(lastOne);
    }
    else if (!mouseCursorOverlaps.empty)
    {
      auto overlappingEntity = mouseCursorOverlaps.front;
      auto overlappingCollider = systemSet.collisionHandler.getComponent(overlappingEntity);
      inputWindow = createText(overlappingEntity.debugInfo, 
                               overlappingEntity.values["position"].myTo!vec2);
      inputWindow.values["connect to entity - ensure position is kept relative to connecting entity"] = overlappingEntity.id.to!string;
      systemSet.addEntity(inputWindow);
    }
    else if (mouseCursorOverlaps.empty)
    {
      if (inputWindow !is null)
        systemSet.removeEntity(inputWindow);
        
      inputWindow = createText("input: ", mouseCursor.values["position"].myTo!vec2);
      inputWindow.values["inputType"] = "textInput";
      systemSet.addEntity(inputWindow);
    }
    else
    {
      assert(0);
    }
  }
  
  /*if (inputWindow !is null)
  {
    inputWindow.values["position"] = mouseCursor.values["position"];
  }*/
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
