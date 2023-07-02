module components.npc;

import std.conv;

import bindbc.sdl;

import entity;
import inputdefaults;


class Npc
{
  //Entity target;
  string targetName;
  
  // TODO: behaviour rule heuristics, weights, etc
  //this(Entity target)
  this(string targetName)
  {
    //this.target = target;
    this.targetName = targetName;
  }
}
