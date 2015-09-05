module entityspawns;

import std.algorithm;
import std.random;

import gl3n.linalg;

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

void addBullets(ref Entity[] npcs, SystemSet systemSet)
{
  // npcs firing randomly
  Entity[] npcBullets;
  foreach (npc; npcs.filter!(npc => systemSet.collisionHandler.getComponent(npc).type == 
                                    ColliderType.Npc))
  {
    if (uniform(1, 180) == 1)
    {
      assert(npc.has("position"));
      assert(npc.has("velocity"));
      assert(npc.has("angle"));
      
      auto angle = npc.get!double("angle");
      
      auto bullet = createBullet(npc.get!vec3("position"),
                                 angle,
                                 npc.get!vec3("velocity") + vec3(vec2FromAngle(angle), 0.0) * 5.0, 
                                 5.0,
                                 npc.id);
      assert(bullet !is null);
      npcBullets ~= bullet;
    }
  }
  foreach (bullet; npcBullets)
  {
    systemSet.addEntity(bullet);
    //npcs ~= bullet;
  }
  npcBullets.length = 0;
}
