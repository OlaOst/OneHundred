module entityfactory.controllers;

import entity;


Entity createGameController()
{
  auto gameController = new Entity();
  gameController.values["input"] = "gameControls";
  return gameController;
}

Entity createEditController()
{
  auto editController = new Entity();
  editController.values["input"] = "textInput";
  return editController;
}
