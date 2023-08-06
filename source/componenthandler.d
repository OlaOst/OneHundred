module componenthandler;

import entity;


interface ComponentHandler(ComponentType)
{
  protected bool canAddEntity(Entity entity);
  protected ComponentType makeComponent(Entity entity);
  protected void updateFromEntities();
  protected void updateValues(bool paused);
  protected void updateEntities();
}
