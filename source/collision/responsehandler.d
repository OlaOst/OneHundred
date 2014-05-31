module collision.responsehandler;

import std.algorithm;
import std.math;
import std.range;
import std.stdio;

import gl3n.linalg;

import collision.check;
import collision.response.ship;
import components.collider;
import components.sound;
import systems.collisionhandler;
import timer;


struct Collision
{
  CollisionEntity first, other;
  
  void updateFromEntities()
  {
    first.updateFromEntity();
    other.updateFromEntity();
  }
}

void handleCollisions(Collision[] collisions)
{
  foreach (collision; collisions)
  {
    auto first = collision.first;
    auto other = collision.other;
    
    auto typePair = (first.collider.type < other.collider.type) ? 
                      tuple(first.collider.type, other.collider.type) : 
                      tuple(other.collider.type, first.collider.type);
    
    if (typePair == tuple(ColliderType.Player, ColliderType.Cursor))
      writeln("player pointing, first ", first.collider.type, ", other ", other.collider.type); 
    if (typePair == tuple(ColliderType.Npc, ColliderType.Bullet))
      writeln("bullethit, first ", first.collider.type, ", other ", other.collider.type);

    // TODO: make separate functions for different collidertype pairs, 
    // i.e. npc/bullet, npc/player...
    if (first.collider.type == ColliderType.Cursor || other.collider.type == ColliderType.Cursor)
      continue;
    
    collision.shipCollisionResponse();
  }
}
