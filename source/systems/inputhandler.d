module systems.inputhandler;

import std.algorithm;
import std.stdio;
import std.string;

import derelict.sdl2.sdl;
import gl3n.linalg;

import components.input;
import converters;
import entity;
import navigationinput;
import system;


class InputHandler : System!Input
{
  public override bool canAddEntity(Entity entity)
  {
    return entity.has("inputType") && !entity.has("remoteEntityId");
  }

  public override Input makeComponent(Entity entity)
  {
    return new Input(entity.get!string("inputType"));
  }

  public override void updateValues()
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
      process(entity, eventsSinceLastUpdate);
  }

  public override void updateEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      entity.updateValues(components[index]);
    }
  }

  public override void updateFromEntities()
  {
  }

  public void process(Entity entity, SDL_Event[] events)
  {
    auto input = getComponent(entity);

    // TODO: only set edittext for components that want to edit text
    entity["editText"] = textInput;

    input.updateActionStates();

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
        if (event.type == SDL_MOUSEBUTTONDOWN)
          input.actionState[*buttonAction] = Input.ActionState.Released;
        if (event.type == SDL_MOUSEBUTTONUP)
          input.actionState[*buttonAction] = Input.ActionState.Pressed;
      }
    }
  }

  private SDL_Event[] eventsSinceLastUpdate;
  private string textInput;
  public vec2 mouseScreenPosition = vec2(0.0, 0.0);
}
