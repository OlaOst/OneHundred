module systems.timehandler;

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
    return ("lifeTime" in entity.scalars) !is null;
  }
  
  override double makeComponent(Entity entity)
  {
    return entity.scalars["lifeTime"];
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
