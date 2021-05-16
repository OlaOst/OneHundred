module components.sound;

import std;

import bindbc.openal;
import gl3n.linalg;

import audio.source;


class Sound
{  
  Source source;
  bool isPlaying = false;
  
  Source getSource() { return source; }
  
  this(Source source)
  {
    this.source = source;
  }
  
  bool stoppedPlaying()
  {
    return !source.isPlaying;
  }
  
  void startPlaying()
  {    
    vec3 position = vec3(300.0, 0.0, 0.0);
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
