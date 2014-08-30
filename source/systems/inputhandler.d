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
  vec2 mouseScreenPosition = vec2(0.0, 0.0);
  
  override bool canAddEntity(Entity entity)
  {
    return ("input" in entity.values) !is null;
  }
  
  override Input makeComponent(Entity entity)
  {
    if (entity.values["input"] == "playerInput")
      return new Input(Input.playerInput);
    if (entity.values["input"] == "gameControls")
      return new Input(Input.gameControls);
    if (entity.values["input"] == "textInput")
      return new Input(Input.textInput);
      
    assert(false, "Found unhandled input value: " ~ entity.values["input"]);
    //return new Input(entity.values["input"].to!(Input.InputForAction));
  }
  
  override void update()
  {
    textInput = "";
    eventsSinceLastUpdate.length = 0;
    
    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
      eventsSinceLastUpdate ~= event;
      
      if (event.type == SDL_MOUSEMOTION)
        mouseScreenPosition = vec2(event.motion.x, event.motion.y);
        
      if (event.type == SDL_TEXTINPUT)
        textInput ~= event.text.text.toStringz.to!string;
    }
    
    foreach (int index, Entity entity; entityForIndex)
      process(entity, eventsSinceLastUpdate);
  }
  
  void process(Entity entity, SDL_Event[] events)
  {
    auto input = getComponent(entity);
    
    // TODO: only set edittext for components that want to edit text
    entity.values["editText"] = textInput;
    
    input.updateActionStates();
    
    foreach (event; events)
    {
      auto keyAction = (event.key.keysym.sym in input.inputForAction.key);
      if (keyAction !is null)
      {
        string action = *keyAction;
        if (event.type == SDL_KEYUP)
          input.actionState[action] = Input.ActionState.Released;
        if (event.type == SDL_KEYDOWN)
          input.actionState[action] = Input.ActionState.Pressed;
      }
      
      auto buttonAction = (event.button.button in input.inputForAction.button);
      if (buttonAction !is null)
      {
        string action = *buttonAction;
        
        if (event.type == SDL_MOUSEBUTTONDOWN)
          input.actionState[action] = Input.ActionState.Released;
        if (event.type == SDL_MOUSEBUTTONUP)
          input.actionState[action] = Input.ActionState.Pressed;
      }
    }
  }
  
private:
  SDL_Event[] eventsSinceLastUpdate;
  string textInput;
}
