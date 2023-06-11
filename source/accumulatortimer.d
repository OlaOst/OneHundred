module accumulatortimer;

import core.time;
import std.algorithm;


class AccumulatorTimer
{
public:
  this(double maxFrametime, double timeStep)
  {
    this.maxFrametime = maxFrametime;
    this.timeStep = timeStep;
    
    startTime = Duration.zero;
    currentTime = startTime.total!"usecs" * (1.0 / 1_000_000);
  }
  
  void incrementAccumulator() @nogc
  {
    double newTime = cast(double)(MonoTime.currTime - startTime).ticks / MonoTime.ticksPerSecond;
    frameTime = min(newTime - currentTime, maxFrametime);
    
    currentTime = newTime;
    accumulator += frameTime;
  }

  private Duration startTime;
  public double currentTime;
  
  public double frameTime = 0.0;
  
  public immutable double maxFrametime;
  public immutable double timeStep;
  public double accumulator = 0.0;
}
