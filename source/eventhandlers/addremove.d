module eventhandlers.addremove;

import std.algorithm;
import std.array;

import components.input;
import entity;
import entityfactory.entities;
import systemset;


void handleAddRemoveEntity(Input gameInput, SystemSet systemSet, ref Entity[] npcs)
{
  gameInput.setAction("addEntity", addEntity);
  gameInput.setAction("removeEntity", removeEntity);
  if (addEntity)
  {
    auto entity = createEntities(1)[0];
    systemSet.addEntity(entity);
    npcs ~= entity;
  }
  
  if (removeEntity && npcs.length > 0)
  {
    auto entity = npcs[$-1];
    systemSet.removeEntity(entity);
    npcs.popBack();
  }
}

bool addEntity = false;
bool removeEntity = false;
