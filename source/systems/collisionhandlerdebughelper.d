module systems.collisionhandlerdebughelper;

import std.datetime.stopwatch;
import std.format;


string getDebugText(StopWatch broadPhaseTimer, StopWatch narrowPhaseTimer,
                    ulong candidates, ulong collisions)
{
  static enum double dampingFactor = 0.9;
  static double dampenedBroadPhaseTimer = 0.0;
  static double dampenedNarrowPhaseTimer = 0.0;
  dampenedBroadPhaseTimer = dampenedBroadPhaseTimer * dampingFactor +
                            broadPhaseTimer.peek.total!"usecs" * (1.0 - dampingFactor);
  dampenedNarrowPhaseTimer = dampenedNarrowPhaseTimer * dampingFactor +
                             narrowPhaseTimer.peek.total!"usecs" * (1.0 - dampingFactor);
  return format("collisionhandler checked %s/%s candidates\nbroadphase/narrowphase",
                candidates, collisions) ~
         format("\ncollisionhandler timings %s/%s milliseconds\nbroadphase/narrowphase",
                cast(int)(dampenedBroadPhaseTimer*0.001),
                cast(int)(dampenedNarrowPhaseTimer*0.001));
}
