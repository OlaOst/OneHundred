module eventhandlers.addremove;

import std.algorithm;
import std.array;
import std.conv;

import components.input;
import entity;
import entityfactory.entities;
import entityfactory.entitycollection;
import systemset;


void handleAddRemoveEntity(Input gameInput, SystemSet systemSet, ref Entity[string][] npcEntityGroups)
{
  bool addEntity = gameInput.isActionSet("addEntity");
  bool removeEntity = gameInput.isActionSet("removeEntity");
  if (addEntity)
  {
    //auto npcEntityGroup = createNpcEntityGroup();
    auto npcEntityGroup = "data/npcship.txt".createEntityCollectionFromFile;
    
    //foreach (npcEntity; npcEntityGroup)
      //systemSet.addEntity(npcEntity);
      
    systemSet.addEntityCollection(npcEntityGroup);
      
    npcEntityGroups ~= npcEntityGroup;
  }
  
  if (removeEntity && npcEntityGroups.length > 0)
  {
    auto entityGroup = npcEntityGroups[$-1];
    
    entityGroup.each!(entity => entity["ToBeRemoved"] = true);
  }
}
