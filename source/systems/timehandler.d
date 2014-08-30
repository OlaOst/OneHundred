module systems.timehandler;

import std.conv;

import entity;
import system;
import timer;


final class TimeHandler : System!double
{
  Timer timer;

  void setTimer(Timer timer)
  {
    this.timer = timer;
  }
  
  override bool canAddEntity(Entity entity)
  {
    return ("lifeTime" in entity.values) !is null;
  }
  
  override double makeComponent(Entity entity)
  {
    return entity.values["lifeTime"].to!double;
  }
  
  override void update()
  {
    foreach (int index, ref double lifeTime; components)
    {
      lifeTime -= timer.frameTime;     
      
      if (lifeTime <= 0.0)
        entityForIndex[index].toBeRemoved = true;
    }
  }
}
