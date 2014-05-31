module collision.responsehandler;

import std.range;
import std.stdio;

import collision.check;
import collision.response.bullet;
import collision.response.ship;
import components.collider;
import entity;
import systems.collisionhandler;


struct Collision
{
  CollisionEntity first, other;
  
  void updateFromEntities()
  {
    first.updateFromEntity();
    other.updateFromEntity();
  }
}

Entity[] handleCollisions(Collision[] collisions)
{
  Entity[] collisionEffectParticles;

  foreach (collision; collisions)
  {
    auto first = collision.first;
    auto other = collision.other;
    
    assert(first.collider !is null);
    assert(other.collider !is null);
    
    auto typePair = (first.collider.type < other.collider.type) ? 
                      tuple(first.collider.type, other.collider.type) : 
                      tuple(other.collider.type, first.collider.type);
    
    if (typePair == tuple(ColliderType.Player, ColliderType.Cursor))
      writeln("player pointing, first ", first.collider.type, ", other ", other.collider.type); 
    /*if (typePair == tuple(ColliderType.Npc, ColliderType.Bullet))
      writeln("bullethit, first ", first.collider.type, ", other ", other.collider.type);*/

    // TODO: make separate functions for different collidertype pairs, 
    // i.e. npc/bullet, npc/player... 
    if (first.collider.type == ColliderType.Cursor || other.collider.type == ColliderType.Cursor)
      continue;
    
    if (typePair[0] != ColliderType.Player && 
        (first.collider.type == ColliderType.Bullet || other.collider.type == ColliderType.Bullet) && 
        (first.collider.spawner is null || first.collider.spawner != other) && (other.collider.spawner is null || other.collider.spawner != first))
      collisionEffectParticles ~= collision.bulletCollisionResponse();
    else
      collision.shipCollisionResponse();
  }
  
  return collisionEffectParticles;
}
