module systems.inputhandler;

import std.algorithm;
import std.stdio;
import std.string;

import derelict.sdl2.sdl;
import gl3n.linalg;

import components.input;
import entity;
import system;


class InputHandler : System!Input
{
public:
  Input[] inputs;
  
  vec2 mouseScreenPosition = vec2(0.0, 0.0);
  
  override bool canAddEntity(Entity entity)
  {
    return entity.input !is null;
  }
  
  override Input makeComponent(Entity entity)
  {
    return entity.input;
  }
  
  override void update()
  {
    eventsForKey = null;
    eventsForButton = null;
    textInput = "";
    
    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
      if (event.type == SDL_KEYUP || event.type == SDL_KEYDOWN)
        // TODO: does this make a deep copy of the event?
        eventsForKey[event.key.keysym.sym] ~= event; //.dup;
        
      if (event.type == SDL_TEXTINPUT)
      {
        textInput ~= event.text.text.toStringz.to!string;
      }
      
      if (event.type == SDL_MOUSEMOTION)
        mouseScreenPosition = vec2(event.motion.x, event.motion.y);
        
      if (event.type == SDL_MOUSEBUTTONDOWN || event.type == SDL_MOUSEBUTTONUP)
        eventsForButton[event.button.button] ~= event;
    }
    
    foreach (int index, Entity entity; entityForIndex)
      process(entity);
  }
  
  void process(Entity entity)
  {
    auto input = entity.input;
    
    // TODO: only set edittext for components that want to edit text
    entity.editText = textInput;
    
    foreach (string action, SDL_Keycode key; input.inputForAction.key)
    {
      if (input.actionState[action] == Input.ActionState.Released)
        input.actionState[action] = Input.ActionState.Inactive;
      if (input.actionState[action] == Input.ActionState.Pressed)
        input.actionState[action] = Input.ActionState.Held;
        
      if (key in eventsForKey)
      {
        // TODO: here we assume that the ordering of events in the eventsForKey[key] array 
        //       corresponds to the order they were pressed in 
        //       that should be tested or confirmed in some way
        foreach(event; eventsForKey[key])
        {
          if (event.type == SDL_KEYUP)
            input.actionState[action] = Input.ActionState.Released;
          if (event.type == SDL_KEYDOWN)
            input.actionState[action] = Input.ActionState.Pressed;
        }
      }
    }
    
    foreach (string action, Uint8 button; input.inputForAction.button)
    {
      if (input.actionState[action] == Input.ActionState.Released)
        input.actionState[action] = Input.ActionState.Inactive;
      if (input.actionState[action] == Input.ActionState.Pressed)
        input.actionState[action] = Input.ActionState.Held;
        
      if (button in eventsForButton)
      {
        // TODO: here we assume that the ordering of events in the eventsForButton[button] array 
        //       corresponds to the order they were pressed in 
        //       that should be tested or confirmed in some way
        foreach(event; eventsForButton[button])
        {
          writeln("handling mouse button event");
          if (event.type == SDL_MOUSEBUTTONDOWN)
            input.actionState[action] = Input.ActionState.Released;
          if (event.type == SDL_MOUSEBUTTONUP)
            input.actionState[action] = Input.ActionState.Pressed;
        }
      }
    }
  }
  
private:
  SDL_Event[][SDL_Keycode] eventsForKey;
  SDL_Event[][Uint8] eventsForButton;
  string textInput;
}
