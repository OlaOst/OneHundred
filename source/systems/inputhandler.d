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

  void updateValues(bool paused)
  {
    textInput = "";
    eventsSinceLastUpdate.length = 0;

    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
      eventsSinceLastUpdate ~= event;
      if (event.type == SDL_EventType.mouseMotion)
        mouseScreenPosition = vec2(event.motion.x, event.motion.y);
      if (event.type == SDL_EventType.textInput)
        textInput ~= event.text.text.to!string;

      import std.stdio;
      if (textInput.canFind("\r"))
        writeln("detected linebreak");
    }

    foreach (size_t index, Entity entity; entityForIndex)
      processSDLEvents(entity, eventsSinceLastUpdate, paused);
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

  void processSDLEvents(Entity entity, SDL_Event[] events, bool paused)
  {      
    auto input = getComponent(entity);

    // TODO: only set edittext for components that want to edit text
    entity["editText"] = textInput;

    input.updateActionStates(paused);

    if (paused && input.inputForAction.ignoreWhenPaused)
    {
      foreach (SDL_Keycode key, string action; input.inputForAction.key)
        input.actionState[action] = Input.ActionState.Inactive;
      return;
    }

    foreach (event; events)
    {
      auto keyAction = (event.key.key in input.inputForAction.key);
      if (keyAction !is null)
      {
        if (event.type == SDL_EventType.keyUp)
          input.actionState[*keyAction] = Input.ActionState.Released;
        if (event.type == SDL_EventType.keyDown)
          input.actionState[*keyAction] = Input.ActionState.Pressed;
      }

      auto buttonAction = (event.button.button in input.inputForAction.button);
      if (buttonAction !is null)
      {
        if (event.type == SDL_EventType.mouseButtonUp)
          input.actionState[*buttonAction] = Input.ActionState.Released;
        if (event.type == SDL_EventType.mouseButtonDown)
          input.actionState[*buttonAction] = Input.ActionState.Pressed;
      }
    }
  }
  
  Entity[] spawnEntities;
  
  private SDL_Event[] eventsSinceLastUpdate;
  private string textInput;
  public vec2 mouseScreenPosition = vec2(0.0, 0.0);
}
