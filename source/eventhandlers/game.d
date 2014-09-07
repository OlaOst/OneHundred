module eventhandlers.game;

import gl3n.linalg;

import components.input;
import systems.graphics;
import systemset;


void handleQuit(Input gameInput)
{
  quit = gameInput.isActionSet("quit");
}

void handleZoom(Input gameInput, Graphics graphics)
{
  zoomIn = gameInput.isActionSet("zoomIn");
  zoomOut = gameInput.isActionSet("zoomOut");
  if (zoomIn)
    graphics.zoom += graphics.zoom * 1.0/60.0;
  if (zoomOut)
    graphics.zoom -= graphics.zoom * 1.0/60.0;
}


bool quit = false;
bool zoomIn = false;
bool zoomOut = false;
