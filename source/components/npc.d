module components.npc;

import std.conv;

import bindbc.sdl;

import entity;
import inputdefaults;


class Npc
{
  enum ActionState
  {
    Unknown,
    Inactive,
    Pressed,
    Held,
    Released,
  }
  
  //Entity target;
  string targetName;
  
  ActionState[string] actionState;
  
  // TODO: behaviour rule heuristics, weights, etc
  //this(Entity target)
  this(string targetName)
  {
    //this.target = target;
    this.targetName = targetName;
  }
  
  void setAction(string action)
  {
    actionState[action] = ActionState.Pressed;
  }
  
  void resetAction(string action)
  {
    actionState[action] = ActionState.Released;
  }
}
