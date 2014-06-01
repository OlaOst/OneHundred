module entityspawns;

import std.algorithm;
import std.random;

import components.collider;
import entity;
import entityfactory.entities;
import systemset;


void addParticles(ref Entity[] particles, SystemSet systemSet)
{
  // particle effects
  particles ~= systemSet.collisionHandler.collisionEffectParticles;
  foreach (collisionEffectParticle; systemSet.collisionHandler.collisionEffectParticles)
    systemSet.addEntity(collisionEffectParticle);
  systemSet.collisionHandler.collisionEffectParticles.length = 0;
}

void addBullets(ref Entity[] npcs, SystemSet systemSet)
{
  // npcs firing randomly
  Entity[] npcBullets;
  foreach (npc; npcs.filter!(npc => npc.collider !is null && 
                                    npc.collider.type == ColliderType.Npc))
  {
    if (uniform(1, 180) == 1)
    {
      assert("position" in npc.vectors);
      assert("velocity" in npc.vectors);
      assert("angle" in npc.scalars);
      auto bullet = createBullet(npc.vectors["position"], 
                                 npc.scalars["angle"], 
                                 npc.vectors["velocity"],
                                 5.0);
      bullet.collider.spawner = npc;
      assert(bullet !is null);
      npcBullets ~= bullet;
    }
  }
  foreach (bullet; npcBullets)
  {
    systemSet.addEntity(bullet);
    npcs ~= bullet;
  }
  npcBullets.length = 0;
}
