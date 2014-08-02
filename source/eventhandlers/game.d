module eventhandlers.game;

import gl3n.linalg;

import components.input;
import systems.graphics;
import systemset;


void handleQuit(Input gameInput)
{
  gameInput.setAction("quit", quit);
}

void handleZoom(Input gameInput, Graphics graphics)
{
  gameInput.setAction("zoomIn", zoomIn);
  gameInput.setAction("zoomOut", zoomOut);
  if (zoomIn)
    graphics.zoom += graphics.zoom * 1.0/60.0;
  if (zoomOut)
    graphics.zoom -= graphics.zoom * 1.0/60.0;
}


bool quit = false;
bool zoomIn = false;
bool zoomOut = false;
