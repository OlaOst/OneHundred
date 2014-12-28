module timer;

import std.algorithm;
import std.datetime;


class Timer
{
public:
  this()
  {
    currentTime = timer.peek().usecs * (1.0 / 1_000_000);
  }

  void start()
  {
    timer.start();
  }
  
  void incrementAccumulator()
  {
    double newTime = timer.peek().usecs * (1.0 / 1_000_000);
    frameTime = min(newTime - currentTime, maxFrametime);
    
    currentTime = newTime;
    accumulator += frameTime;
    import std.stdio;
    //writeln("fps: ", 1.0/frameTime);
  }

  private StopWatch timer;
  private double currentTime;
  
  public double frameTime = 0.0;
  
  public double time = 0.0;
  public static const double maxFrametime = 0.25;
  public static const double physicsTimeStep = 1.0 / 60.0;
  public double accumulator = 0.0;
}
