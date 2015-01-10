module eventhandlers.toggleinputwindow;

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
  auto overlappingTexts = mouseCursorOverlaps.filter!(overlap => 
                            overlap.type == ColliderType.GuiElement);

  // right click to toggle input window 
  // close input windows if right clicked, open input window for overlapping entity
  // open new empty input window if no overlaps
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
      if (inputWindow !is null && lastOne.id == inputWindow.id)
        inputWindow = null;
    }
    else if (!mouseCursorOverlaps.empty)
    {
      auto overlappingCollider = mouseCursorOverlaps.front;
      auto overlappingEntity = systemSet.collisionHandler.getEntity(overlappingCollider);
      auto relativePosition = vec2(overlappingEntity.get!double("size") * 2.0, 0.0);
      
      inputWindow = createText(overlappingEntity.debugInfo, 
                               overlappingEntity.get!vec2("position"));
      inputWindow.values["relation.types"] = ["RelativeValues", "InspectValues"].to!string;
      inputWindow.values["relation.value.position"] = relativePosition.to!string;
      inputWindow.values["relation.targetId"] = overlappingEntity.id.to!string;
      systemSet.addEntity(inputWindow);
      
      auto inputWindowAABB = systemSet.textGraphics.getComponent(inputWindow).aabb;
      auto inputWindowCover = createTextCover(inputWindow, inputWindowAABB);
      systemSet.addEntity(inputWindowCover);
    }
    else if (mouseCursorOverlaps.empty)
    {
      if (inputWindow !is null)
        inputWindow.toBeRemoved = true;

      inputWindow = createText("input: ", mouseCursor.get!vec2("position"));
      inputWindow.values["inputType"] = "textInput";
      systemSet.addEntity(inputWindow);
      
      auto inputWindowAABB = systemSet.textGraphics.getComponent(inputWindow).aabb;
      auto inputWindowCover = createTextCover(inputWindow, inputWindowAABB);
      systemSet.addEntity(inputWindowCover);
    }
    else
    {
      assert(0);
    }
  }
}
