module timer;

import std.datetime;


class Timer
{
public:
  this()
  {
    timer.start();
    currentTime = timer.peek().usecs * (1.0 / 1_000_000);
  }

  void incrementAccumulator()
  {
    double newTime = timer.peek().usecs * (1.0 / 1_000_000);
    double frameTime = newTime - currentTime;
    currentTime = newTime;
    accumulator += frameTime;
  }

  private StopWatch timer;
  private double currentTime;
  
  public double time = 0.0;
  public static const double physicsTimeStep = 1.0 / 60.0;
  public double accumulator = 0.0;
}
