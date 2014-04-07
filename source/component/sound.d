module component.sound;

import std.algorithm;

import derelict.openal.al;
import gl3n.linalg;

import audio.raw;
import audio.source;
import audio.stream;


class Sound
{  
  Source source;
  bool isPlaying = false;
  static Source[string] sourceCache;
  
  Source getSource() { return source; }
  
  this(string fileName)
  {
    if (fileName !in sourceCache)
    {
      if (fileName.endsWith(".wav"))
        sourceCache[fileName] = new Raw(fileName);
        
      if (fileName.endsWith(".ogg"))
        sourceCache[fileName] = new Stream(fileName);
    }
    
    this.source = sourceCache[fileName];
  }
  
  bool stoppedPlaying()
  {
    return !source.isPlaying;
  }
  
  void startPlaying()
  {    
    vec2 position = vec2(300.0, 0.0);
    //if (source.getAlSource().alIsSource)
      //source.getAlSource().alSource3f(AL_POSITION, position.x, position.y, 0.0);
    
    check();
    
    if (!isPlaying)
      source.play();

    isPlaying = true;
  }
  
  void stopPlaying()
  {
    if (isPlaying)
      source.silence();
      
    isPlaying = false;
  }
}
