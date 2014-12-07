module entityspawns;

import std.algorithm;
import std.random;

import gl3n.linalg;

import components.collider;
import converters;
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
  foreach (npc; npcs.filter!(npc => systemSet.collisionHandler.getComponent(npc).type == 
                                    ColliderType.Npc))
  {
    if (uniform(1, 180) == 1)
    {
      assert("position" in npc.values);
      assert("velocity" in npc.values);
      assert("angle" in npc.values);
      
      auto angle = npc.values["angle"].to!double;
      
      auto bullet = createBullet(npc.values["position"].myTo!vec2,
                                 angle,
                                 npc.values["velocity"].myTo!vec2 + vec2FromAngle(angle) * 5.0, 
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
