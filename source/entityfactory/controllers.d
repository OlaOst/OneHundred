module entityfactory.controllers;

import entity;


Entity createGameController()
{
  auto gameController = new Entity();
  gameController.values["inputType"] = "gameControls";
  return gameController;
}

Entity createEditController()
{
  auto editController = new Entity();
  editController.values["inputType"] = "textInput";
  return editController;
}
