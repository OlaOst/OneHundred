module component.sound;

import std.algorithm;

import artemisd.all;
import gl3n.linalg;

import audio.raw;
import audio.source;
import audio.stream;


final class Sound : Component
{
  mixin TypeDecl;
  
  Source source;
  public bool isPlaying = false;
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
  
  void startPlaying()
  {
    source.setPosition(vec2(300.0, 0.0));
    
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
