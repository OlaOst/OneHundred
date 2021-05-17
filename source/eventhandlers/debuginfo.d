module eventhandlers.debuginfo;

import gl3n.linalg;

import components.input;
import entity;
import entityfactory.tests;
import entityfactory.texts;
import systemset;


void handleToggleDebugInfo(Input gameInput, SystemSet systemSet, ref Entity debugText)
{
  static size_t index = 0;
  if (gameInput.isActionToggled("toggleDebugInfo"))
  {
    if (debugText is null)
    {
      debugText = createText("??", vec3(-1.0, -2.0, 0.0));
      systemSet.addEntity(debugText);
    }
    index = (index + 1) % systemSet.entityHandlers.length;
  }
  
  if (debugText !is null)
  {
    debugText["text"] = systemSet.entityHandlers[index].debugText;
    assert(debugText.get!string("text") !is null);
  }
  
  if (gameInput.isActionToggled("toggleDebugEntities"))
  {
    systemSet.toggleDebugEntities();
  }
}
