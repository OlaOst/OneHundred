module system.inputhandler;

import std.algorithm;

import artemisd.all;
import derelict.sdl2.sdl;

import component.input;


final class InputHandler : EntityProcessingSystem
{
public:
  mixin TypeDecl;
 
  this()
  {
    super(Aspect.getAspectForOne!(Input));
  }
  
  void update()
  {
    eventsForKey = null;
    
    SDL_Event event;

    while (SDL_PollEvent(&event))
    {
      if (event.type == SDL_KEYUP || event.type == SDL_KEYDOWN)
        // TODO: does this make a deep copy of the event?
        eventsForKey[event.key.keysym.sym] ~= event; //.dup; 
    }
  }
  
  override void process(Entity entity)
  {
    auto input = entity.getComponent!Input;
    
    // the getaspect thing in the constructor does not work
    // we get entities without input components here
    if (input is null)
      return;
    
    foreach (action, key; input.keyForAction)
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
  
  /*@property bool zoomIn()
  {
    return (SDLK_PAGEUP in eventsForKey) && 
            eventsForKey[SDLK_PAGEUP].any!(event => event.type == SDL_KEYDOWN);
  }
  
  @property bool zoomOut()
  {
    return (SDLK_PAGEDOWN in eventsForKey) && 
            eventsForKey[SDLK_PAGEDOWN].any!(event => event.type == SDL_KEYDOWN);
  }
  
  @property bool keepRunning()
  {
    return !((SDLK_ESCAPE in eventsForKey) && 
            eventsForKey[SDLK_ESCAPE].any!(event => event.type == SDL_KEYUP));
  }*/
  
private:
  SDL_Event[][SDL_Keycode] eventsForKey;
}
