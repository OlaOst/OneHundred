module entityspawns;

import std.algorithm;
import std.conv;
import std.random;

import inmath.linalg;

import components.collider;
import converters;
import entity;
import entityfactory.entities;
import systemset;


void addParticles(SystemSet systemSet)
{
  // TODO: get particle effects from all relevant systems, not just collisionhandler
  // TODO: should be generalized created entities from systems, 
  // TODO: some will be particles, some will be different things
  foreach (collisionEffectParticle; systemSet.collisionHandler.collisionEffectParticles)
    systemSet.addEntity(collisionEffectParticle);
  systemSet.collisionHandler.collisionEffectParticles.length = 0;
}

void addNetworkEntities(SystemSet systemSet)
{
  foreach (entity; systemSet.networkHandler.entitiesToBeAdded)
  {
    //import std.stdio;
    //writeln("adding remoteentity from networkhandler with values ", entity.values);
    systemSet.addEntity(entity);
  }
  systemSet.networkHandler.entitiesToBeAdded.length = 0;
}

void addBullets(ref Entity[string][] npcEntityGroups, SystemSet systemSet)
{
  // npcs firing randomly
  foreach (npcEntityGroup; npcEntityGroups)
  {
    foreach (npcGunEntity; npcEntityGroup.values.filter!(npcEntity => 
                           npcEntity.get!string("fullName") == "npc.ship.gun"))
    {
      if (uniform(1, 180) == 1)
      {
        assert(npcGunEntity.has("position"), npcGunEntity.values.to!string);
        assert(npcGunEntity.has("velocity"), npcGunEntity.values.to!string);
        assert(npcGunEntity.has("angle"), npcGunEntity.values.to!string);
        
        auto angle = npcGunEntity.get!double("angle");
        
        auto bulletEntityGroup = createBulletEntityGroup(npcGunEntity.get!vec3("position"),
                                                         angle,
                                                         npcGunEntity.get!vec3("velocity") + 
                                                         vec3(vec2FromAngle(angle), 0.0) * 5.0, 
                                                         5.0,
                                                         npcGunEntity.id);
        
        assert(bulletEntityGroup !is null && bulletEntityGroup.length > 0);
        
        bulletEntityGroup.each!(bulletEntity => bulletEntity["collisionfilter"] = "npc.ship.*");
        
        systemSet.addEntityCollection(bulletEntityGroup);
      }
    }
  }
}
