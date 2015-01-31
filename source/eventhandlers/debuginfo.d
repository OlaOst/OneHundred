module eventhandlers.debuginfo;

import gl3n.linalg;

import components.input;
import entity;
import entityfactory.texts;
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
    index = (index + 1) % systemSet.entityHandlers.length;
  }
  
  // TODO: ensure entity values get reflected to the relevant components
  /*final switch (index % 3)
  {
    case 0:
      debugText.values["text"] = systemSet.collisionHandler.debugText;
      break;
    case 1:
      debugText.values["text"] = systemSet.physics.debugText;
      break;
    case 2:
      debugText.values["text"] = systemSet.graphicsTimingText;
      break;
  }*/
  
  debugText.values["text"] = systemSet.entityHandlers[index].debugText;
  
  assert(debugText.values["text"] !is null);
}
