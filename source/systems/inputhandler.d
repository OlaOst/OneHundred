module systems.inputhandler;

import std;

import bindbc.sdl;
import inmath.linalg;

import components.input;
import converters;
import entity;
import navigationinput;
import system;


class InputHandler : System!Input
{
  bool canAddEntity(Entity entity)
  {
    return entity.has("inputType") && !entity.has("remoteEntityId");
  }

  Input makeComponent(Entity entity)
  {
    return new Input(entity.get!string("inputType"));
  }

  void updateValues()
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

      import std.stdio;
      if (textInput.canFind("\r"))
        writeln("detected linebreak");
    }

    foreach (size_t index, Entity entity; entityForIndex)
      processSDLEvents(entity, eventsSinceLastUpdate);
  }

  void updateEntities()
  {
    spawnEntities.length = 0;
    foreach (index, entity; entityForIndex)
    {
      spawnEntities ~= entity.updateValuesAndGetSpawns(components[index]);
    }
  }

  void updateFromEntities() {}

  void processSDLEvents(Entity entity, SDL_Event[] events)
  {
    auto input = getComponent(entity);

    // TODO: only set edittext for components that want to edit text
    entity["editText"] = textInput;

    input.updateActionStates();

    input.actionState["zoomIn"] = Input.ActionState.Released;
    input.actionState["zoomOut"] = Input.ActionState.Released;

    foreach (event; events)
    {
      auto keyAction = (event.key.keysym.sym in input.inputForAction.key);
      if (keyAction !is null)
      {
        if (event.type == SDL_KEYUP)
          input.actionState[*keyAction] = Input.ActionState.Released;
        if (event.type == SDL_KEYDOWN)
          input.actionState[*keyAction] = Input.ActionState.Pressed;
      }

      auto buttonAction = (event.button.button in input.inputForAction.button);
      if (buttonAction !is null)
      {
        if (event.type == SDL_MOUSEBUTTONUP)
          input.actionState[*buttonAction] = Input.ActionState.Released;
        if (event.type == SDL_MOUSEBUTTONDOWN)
          input.actionState[*buttonAction] = Input.ActionState.Pressed;
      }
      
      if (event.type == SDL_MOUSEWHEEL)
      {
        Input.InputEvent inputEvent;
        
        debug writeln("mousewheel event, y ", event.wheel.y);
        
        if (event.wheel.y > 0) // up
          inputEvent = Input.InputEvent.WHEELUP;
        if (event.wheel.y < 0) // down
          inputEvent = Input.InputEvent.WHEELDOWN;
          
        auto wheelAction = (inputEvent in input.inputForAction.wheel);
        if (wheelAction !is null)
        {
          if (event.wheel.y == 0)
            input.actionState[*wheelAction] = Input.ActionState.Released;
          else
            input.actionState[*wheelAction] = Input.ActionState.Pressed;
        }
      }
    }
  }
  
  Entity[] spawnEntities;
  
  private SDL_Event[] eventsSinceLastUpdate;
  private string textInput;
  public vec2 mouseScreenPosition = vec2(0.0, 0.0);
}
