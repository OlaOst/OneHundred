module entityfactory.controllers;

import entity;


Entity createGameController()
{
  auto gameController = new Entity();
  gameController["inputType"] = "gameControls";
  return gameController;
}

Entity createEditController()
{
  auto editController = new Entity();
  editController["inputType"] = "textInput";
  return editController;
}
