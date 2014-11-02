module inputdefaults;

import derelict.sdl2.sdl;

import components.input;


static Input.InputForAction playerInput;
static Input.InputForAction gameControls;
static Input.InputForAction textInput;
  
static this()
{
  playerInput.key[SDLK_UP] = "accelerate";
  playerInput.key[SDLK_DOWN] = "decelerate";
  playerInput.key[SDLK_LEFT] = "rotateCounterClockwise";
  playerInput.key[SDLK_RIGHT] = "rotateClockwise";
  playerInput.key[SDLK_SPACE] = "fire";
  
  gameControls.key[SDLK_PAGEUP] = "zoomIn";
  gameControls.key[SDLK_PAGEDOWN] = "zoomOut";
  gameControls.key[SDLK_ESCAPE] = "quit";
  gameControls.key[SDLK_INSERT] = "addEntity";
  gameControls.key[SDLK_DELETE] = "removeEntity";
  gameControls.key[SDLK_F1] = "toggleDebugInfo";
  gameControls.button[SDL_BUTTON_RIGHT] = "toggleInputWindow";
  
  textInput.key[SDLK_BACKSPACE] = "backspace";
}
