module systems.timehandler;

import std.conv;

import accumulatortimer;
import entity;
import system;


final class TimeHandler : System!double
{
  AccumulatorTimer timer;

  this()
  {
    timer = new AccumulatorTimer(0.25, 1.0/60.0);
  }
  
  bool canAddEntity(Entity entity)
  {
    return entity.has("lifeTime");
  }
  
  double makeComponent(Entity entity)
  {
    return entity.get!double("lifeTime");
  }
  
  void updateValues()
  {
    timer.incrementAccumulator();
    
    foreach (int index, ref double lifeTime; components)
    {
      lifeTime -= timer.frameTime;
      
      if (lifeTime <= 0.0)
        entityForIndex[index]["ToBeRemoved"] = true;
    }
  }
  
  void updateEntities()
  {
    foreach (int index, double lifeTime; components)
    {
      entityForIndex[index]["lifeTime"] = lifeTime;
    }
  }
  
  void updateFromEntities() {}
}
