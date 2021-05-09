module systemdebug;

import entityhandler;


abstract class SystemDebug : EntityHandler
{
  double debugTiming() @property
  {
    return debugTimingInternal;
  }
  
  void debugTiming(double debugTimingParameter) @property
  {
    debugTimingInternal = debugTimingParameter;
  }
  
  string debugText() @property
  {
    return debugTextInternal;
  }
  
  void debugText(string debugTextParameter) @property
  {
    debugTextInternal = debugTextParameter;
  }
  
  void close()
  {
  }
  
  /*void update()
  {
    debugTimingInternal = debugTimer.peek.usecs*0.001;
    debugTextInternal = format("%s components: %s\n%s timings: %s", className,
                                                                    components.length,
                                                                    className,
                                                                    debugTimingInternal);
  }*/
  
  double debugTimingInternal;
  string debugTextInternal;
}
