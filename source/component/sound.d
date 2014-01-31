module component.sound;

import artemisd.all;

import audio.stream;


final class Sound : Component
{
  mixin TypeDecl;
  
  Stream stream;
  
  this(string soundFile)
  {
    stream = new Stream(soundFile);
  }
  
  void startPlaying()
  {
    stream.startPlaybackThread();
  }
  
  void stopPlaying()
  {
    stream.silence();
  }
}
