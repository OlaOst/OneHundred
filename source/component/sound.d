module component.sound;

import std.algorithm;

import artemisd.all;

import audio.raw;
import audio.stream;


final class Sound : Component
{
  mixin TypeDecl;
  
  // TODO: should be one component for streaming and another for raw
  Stream stream;
  Raw raw;
  
  public bool isPlaying = false;
  
  static Stream[string] streamCache;
  static Raw[string] rawCache;
  
  static Sound loadSound(string soundFile)
  {   
    if (soundFile.endsWith(".wav"))
    {
      if( soundFile !in rawCache)
        rawCache[soundFile] = new Raw(soundFile);
        
      return new Sound(rawCache[soundFile]);
    }
    else if (soundFile.endsWith(".ogg"))
    {
      if (soundFile !in streamCache)
        streamCache[soundFile] = new Stream(soundFile);
        
      return new Sound(streamCache[soundFile]);
    }
    
    assert(0);
  }
  
  private this(Stream stream)
  {
    this.stream = stream;
  }
  
  private this(Raw raw)
  {
    this.raw = raw;
  }
  
  void startPlaying()
  {
    if (stream !is null)
      stream.startPlaybackThread();
    if (raw !is null)
      raw.play();
      
    isPlaying = true;
  }
  
  void stopPlaying()
  {
    if (stream !is null)
      stream.silence();
      
    isPlaying = false;
  }
}
