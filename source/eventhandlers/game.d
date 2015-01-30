module eventhandlers.game;

import gl3n.linalg;

import app;
import camera;
import components.input;
import systemset;


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

void handleNetworking(Input gameInput, SystemSet systemSet, ushort listenPort)
{
  if (gameInput.isActionSet("attemptNetworkConnection"))
  {
    systemSet.networkHandler.startSendingData(cast(ushort)(listenPort + 1));
  }
}

bool quit = false;
bool zoomIn = false;
bool zoomOut = false;
