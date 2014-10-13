module eventhandlers.game;

import gl3n.linalg;

import camera;
import components.input;


void handleQuit(Input gameInput)
{
  quit = gameInput.isActionSet("quit");
}

void handleZoom(Input gameInput, Camera camera)
{
  zoomIn = gameInput.isActionSet("zoomIn");
  zoomOut = gameInput.isActionSet("zoomOut");
  if (zoomIn)
    camera.zoom += camera.zoom * 1.0/60.0;
  if (zoomOut)
    camera.zoom -= camera.zoom * 1.0/60.0;
}


bool quit = false;
bool zoomIn = false;
bool zoomOut = false;
