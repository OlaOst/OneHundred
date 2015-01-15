module entityhandler;

import entity;


interface EntityHandler
{
  void addEntity(Entity entity);
  void removeEntity(Entity entity);
  void update();
  
  string debugText() @property;
  double debugTiming() @property;
  int componentCount() @property;
  
  string className() @property;
}
