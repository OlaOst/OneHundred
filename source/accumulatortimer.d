module accumulatortimer;

import std.algorithm;
import std.datetime;


class AccumulatorTimer
{
public:
  this(double maxFrametime, double timeStep)
  {
    this.maxFrametime = maxFrametime;
    this.timeStep = timeStep;
    
    timer.start();
    currentTime = timer.peek().usecs * (1.0 / 1_000_000);
  }
  
  void incrementAccumulator()
  {
    double newTime = timer.peek().usecs * (1.0 / 1_000_000);
    frameTime = min(newTime - currentTime, maxFrametime);
    
    currentTime = newTime;
    accumulator += frameTime;
    //import std.stdio;
    //writeln("fps: ", 1.0/frameTime);
  }

  private StopWatch timer;
  public double currentTime;
  
  public double frameTime = 0.0;
  
  //public double time = 0.0;
  public immutable double maxFrametime;// = 0.25;
  public immutable double timeStep;// = 1.0 / 60.0;
  public double accumulator = 0.0;
}
