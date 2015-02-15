module eventhandlers.toggleinputwindow;

import std.algorithm;
import std.array;

import gl3n.linalg;

import components.collider;
import components.input;
import converters;
import entity;
import entityfactory.texts;
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
                            overlap.type == ColliderType.GuiElement && systemSet.collisionHandler.getEntity(overlap).has("text"));

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
      systemSet.collisionHandler.getEntity(lastOne)["ToBeRemoved"] = true;
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
      inputWindow["relation.types"] = ["RelativeValues", "InspectValues"];
      inputWindow["relation.value.position"] = relativePosition;
      inputWindow["relation.targetId"] = overlappingEntity.id;
      systemSet.addEntity(inputWindow);
      
      auto inputWindowAABB = systemSet.textGraphics.getComponent(inputWindow).aabb;
      auto inputWindowCover = createTextCover(inputWindow, inputWindowAABB);
      systemSet.addEntity(inputWindowCover);
    }
    else if (mouseCursorOverlaps.empty)
    {
      if (inputWindow !is null)
        inputWindow["ToBeRemoved"] = true;

      inputWindow = createText("input: ", mouseCursor.get!vec2("position"));
      inputWindow["inputType"] = "textInput";
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
