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
  
  override bool canAddEntity(Entity entity)
  {
    return ("lifeTime" in entity.values) !is null;
  }
  
  override double makeComponent(Entity entity)
  {
    return entity.get!double("lifeTime");
  }
  
  override void updateValues()
  {
    timer.incrementAccumulator();
    
    foreach (int index, ref double lifeTime; components)
    {
      lifeTime -= timer.frameTime;
      
      if (lifeTime <= 0.0)
        entityForIndex[index].values["ToBeRemoved"] = true.to!string;
    }
  }
  
  override void updateEntities()
  {
    foreach (int index, double lifeTime; components)
    {
      entityForIndex[index].values["lifeTime"] = lifeTime.to!string;
    }
  }
  
  override void updateFromEntities()
  {
  }
}
