module timer;

import std.algorithm;
import std.datetime;


class Timer
{
public:
  this(double maxFrametime, double timeStep)
  {
    this.maxFrametime = maxFrametime;
    this.timeStep = timeStep;
        
    timer.start();
    currentTime = timer.peek().usecs * (1.0 / 1_000_000);
  }
  
  void incrementAccumulator() //@nogc
  {
    double newTime = timer.peek().usecs * (1.0 / 1_000_000);
    frameTime = min(newTime - currentTime, maxFrametime);
    
    currentTime = newTime;
    accumulator += frameTime;
  }

  private StopWatch timer;
  private double currentTime;
  
  public double frameTime = 0.0;
  
  public immutable double maxFrametime;
  public immutable double timeStep;
  public double accumulator = 0.0;
}
