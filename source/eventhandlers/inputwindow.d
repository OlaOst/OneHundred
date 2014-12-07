module eventhandlers.inputwindow;

import std.algorithm;
import std.array;

import gl3n.linalg;

import components.collider;
import components.input;
import converters;
import entity;
import entityfactory.tests;
import systemset;


void handleToggleInputWindow(Input gameInput, 
                             SystemSet systemSet, 
                             ref Entity inputWindow, 
                             Entity mouseCursor)
{
  // find out which entities the mouseCursor is overlapping with
  assert(mouseCursor in systemSet.collisionHandler.indexForEntity);
  auto mouseCursorCollider = systemSet.collisionHandler.getComponent(mouseCursor);
  auto mouseCursorOverlaps = mouseCursorCollider.overlappingColliders;
  auto overlappingTexts = mouseCursorOverlaps.filter!(overlap => overlap.type == ColliderType.GuiElement);

  // left click - focus clicked input window to make it editable
  if (gameInput.isActionToggled("focusInputWindow"))
  {
    if (!overlappingTexts.empty)
    {
      if (inputWindow == overlappingTexts.front)
        overlappingTexts.popFront();
      if (!overlappingTexts.empty)
      {
        if (inputWindow !is null)
          systemSet.textGraphics.getComponent(inputWindow).color = vec4(0.5, 0.5, 0.0, 1.0);
        inputWindow = systemSet.collisionHandler.getEntity(overlappingTexts.front);
        systemSet.textGraphics.getComponent(inputWindow).color = vec4(1.0, 1.0, 1.0, 1.0);
      }
    }
    
    // defocus current window
    if (overlappingTexts.empty && inputWindow !is null)
    {
      systemSet.textGraphics.getComponent(inputWindow).color = vec4(0.5, 0.5, 0.0, 1.0);
      inputWindow = null;
    }
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
      systemSet.collisionHandler.getEntity(lastOne).toBeRemoved = true;
      //systemSet.removeEntity(systemSet.collisionHandler.getEntity(lastOne));
      if (inputWindow !is null && lastOne.id == inputWindow.id)
        inputWindow = null;
    }
    else if (!mouseCursorOverlaps.empty)
    {
      auto overlappingCollider = mouseCursorOverlaps.front;
      auto overlappingEntity = systemSet.collisionHandler.getEntity(overlappingCollider);
      inputWindow = createText(overlappingEntity.debugInfo, 
                               overlappingEntity.values["position"].myTo!vec2);
      inputWindow.values["connect to entity - ensure position is kept relative to connecting entity"] = overlappingEntity.id.to!string;
      systemSet.addEntity(inputWindow);
      
      auto inputWindowCover = createTextCover(inputWindow, systemSet.textGraphics.getComponent(inputWindow).aabb);
      systemSet.addEntity(inputWindowCover);
    }
    else if (mouseCursorOverlaps.empty)
    {
      if (inputWindow !is null)
        //systemSet.removeEntity(inputWindow);
        inputWindow.toBeRemoved = true;

      inputWindow = createText("input: ", mouseCursor.values["position"].myTo!vec2);
      inputWindow.values["inputType"] = "textInput";
      systemSet.addEntity(inputWindow);
      
      auto inputWindowCover = createTextCover(inputWindow, systemSet.textGraphics.getComponent(inputWindow).aabb);
      systemSet.addEntity(inputWindowCover);
    }
    else
    {
      assert(0);
    }
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
