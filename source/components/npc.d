module components.npc;

import std.conv;

import bindbc.sdl;

import entity;
import inputdefaults;


class Npc
{
  Entity target;
  
  // TODO: behaviour rule heuristics, weights, etc
  this(Entity target)
  {
    this.target = target;
  }
}
