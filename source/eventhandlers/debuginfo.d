module eventhandlers.debuginfo;

import gl3n.linalg;

import components.input;
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
