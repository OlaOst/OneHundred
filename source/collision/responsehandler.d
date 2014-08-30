module collision.responsehandler;

import std.range;
import std.stdio;

import collision.collisionentity;
import collision.response.bullet;
import collision.response.ship;
import components.collider;
import entity;
import systems.collisionhandler;
import systemset;


struct Collision
{
  Collider first, other;
  
  /*void updateFromEntities()
  {
    first.updateFromEntity();
    other.updateFromEntity();
  }*/
}

Entity[] handleCollisions(Collision[] collisions, SystemSet systemSet)
{
  Entity[] collisionEffectParticles;

  foreach (collision; collisions)
  {
    auto first = collision.first;
    auto other = collision.other;
    
    //assert(first !is null);
    //assert(other !is null);
    
    auto typePair = (first.type < other.type) ? 
                      [first.type, other.type] : 
                      [other.type, first.type];
    
    //if (typePair == [ColliderType.Player, ColliderType.Cursor])
      //writeln("player pointing, first ", first.type, ", other ", other.type);
    /*if (typePair == tuple(ColliderType.Npc, ColliderType.Bullet))
      writeln("bullethit, first ", first.type, ", other ", other.type);*/

    // TODO: make separate functions for different collidertype pairs, 
    // i.e. npc/bullet, npc/player... 
    if (first.type == ColliderType.Cursor || other.type == ColliderType.Cursor)
      continue;
    
    auto firstEntity = systemSet.collisionHandler.getEntity(first);
    auto otherEntity = systemSet.collisionHandler.getEntity(other);
    
    if (typePair[0] != ColliderType.Player && 
        (first.type == ColliderType.Bullet || 
         other.type == ColliderType.Bullet) && 
        first.spawner !is otherEntity && other.spawner !is firstEntity)
      collisionEffectParticles ~= collision.bulletCollisionResponse(systemSet);
    else if (first.spawner !is otherEntity && other.spawner !is firstEntity)
      collisionEffectParticles ~= collision.shipCollisionResponse(systemSet);
  }
  
  return collisionEffectParticles;
}
