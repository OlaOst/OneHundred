module systems.inputhandler;

import std.algorithm;

import derelict.sdl2.sdl;
import gl3n.linalg;

import component.input;
import entity;
import system;


class InputHandler : System
{
public:
  Input[] inputs;
  
  vec2 mouseScreenPosition = vec2(0.0, 0.0);
  
  override bool canAddEntity(Entity entity)
  {
    return entity.input !is null;
  }
  
  override void addEntity(Entity entity)
  {
    if (canAddEntity(entity))
    {
      indexForEntity[entity] = inputs.length;
      entityForIndex[inputs.length] = entity;
      
      inputs ~= entity.input;
    }
  }
  
  override void update()
  {
    foreach (int index, Entity entity; entityForIndex)
      process(entity);
  
    eventsForKey = null;
    
    SDL_Event event;

    while (SDL_PollEvent(&event))
    {
      if (event.type == SDL_KEYUP || event.type == SDL_KEYDOWN)
        // TODO: does this make a deep copy of the event?
        eventsForKey[event.key.keysym.sym] ~= event; //.dup;
        
      if (event.type == SDL_MOUSEMOTION)
        mouseScreenPosition = vec2(event.motion.x, event.motion.y);
    }
  }
  
  void process(Entity entity)
  {
    //auto input = entity.getComponent!Input;
    auto input = entity.input;
    
    // the getaspect thing in the constructor does not work
    // we get entities without input components here
    //if (input is null)
      //return;
    
    foreach (string action, SDL_Keycode key; input.keyForAction)
    {
      if (key in eventsForKey)
      {
        // TODO: here we assume that the ordering of events in the eventsForKey[key] array 
        //       corresponds to the order they were pressed in 
        //       that should be tested or confirmed in some way
        foreach(event; eventsForKey[key])
        {
          if (event.type == SDL_KEYUP)
            input.isActive[action] = false;
          if (event.type == SDL_KEYDOWN)
            input.isActive[action] = true;
        }
      }
    }
  }
  
private:
  SDL_Event[][SDL_Keycode] eventsForKey;
}