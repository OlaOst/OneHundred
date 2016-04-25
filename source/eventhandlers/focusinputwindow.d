module eventhandlers.focusinputwindow;

import std.algorithm;
import std.range;

import gl3n.linalg;

import components.collider;
import components.input;
import entity;
import systemset;
import systems.collisionhandler;


void handleFocusInputWindow(Input gameInput, 
                            SystemSet systemSet, 
                            ref Entity inputWindow, 
                            Entity mouseCursor)
{
  // find out which entities the mouseCursor is overlapping with
  assert(mouseCursor in systemSet.collisionHandler.indexForEntity);
  auto mouseCursorCollider = systemSet.collisionHandler.getComponent(mouseCursor);
  auto mouseCursorOverlaps = mouseCursorCollider.overlappingColliders;
  auto overlappingTexts = mouseCursorOverlaps.filter!(overlap => 
                            overlap.type == ColliderType.GuiElement);

  // left click - focus clicked input window to make it editable
  if (gameInput.isActionToggled("focusInputWindow"))
  {
    auto component = systemSet.graphics.getComponent(inputWindow);
  
    if (!overlappingTexts.empty)
    {
      if (inputWindow == overlappingTexts.front)
        overlappingTexts.popFront();
        
      if (!overlappingTexts.empty)
      {
        if (inputWindow !is null)
          component.data.setColor(vec4(0.5, 0.5, 0.0, 1.0));
          
        inputWindow = systemSet.collisionHandler.getEntity(overlappingTexts.front);
        component.data.setColor(vec4(1.0, 1.0, 1.0, 1.0));
      }
    }
    
    // defocus current window
    if (overlappingTexts.empty && inputWindow !is null)
    {
      component.data.setColor(vec4(0.5, 0.5, 0.0, 1.0));
      inputWindow = null;
    }
  }
}