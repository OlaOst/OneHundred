module audio.stream;

import std.algorithm;
import std.conv;
import std.exception;
import std.parallelism;
import std.stdio;

import derelict.ogg.ogg;
import derelict.vorbis.vorbis;
import derelict.vorbis.file;
import derelict.openal.al;

import audio.oggsource;
import audio.source;


class Stream : Source
{
public:
  this(string fileName)
  {
    oggSource = OggSource(fileName);

    alGenBuffers(buffers.length, buffers.ptr);
    enforce(buffers[].all!(buffer => buffer.alIsBuffer));
    
    source = Source.findFreeSource();
    check();
  }
  
  void play()
  {
    startPlaybackThread();
  }
  
  void silence()
  {
    keepPlaying = false;
  }
  
private:
  void startPlaybackThread()
  {
    auto playbackTask = task(&this.playbackLoop);
    playbackTask.executeInNewThread();
  }
  
  void playbackLoop()
  {
    while (update() && keepPlaying)
      if (!source.isPlaying)
        enforce(playback(), "Ogg abruptly stopped");
  }
  
  bool update()
  {
    int buffersProcessed;
    bool isActive = true;
    
    source.alGetSourcei(AL_BUFFERS_PROCESSED, &buffersProcessed);
    
    while (buffersProcessed--)
    {
      ALuint buffer;
      source.alSourceUnqueueBuffers(1, &buffer);
      check();
      
      isActive = buffer.stream(oggSource);
      if (isActive)
        source.alSourceQueueBuffers(1, &buffer);
      check();
    }
    
    return isActive;
  }
  
  bool playback()
  {
    if (source.isPlaying)
      return true;
    
    if (buffers[].any!(buffer => !buffer.stream(oggSource)))
      return false;
    
    source.alSourceQueueBuffers(buffers.length, buffers.ptr);
    source.alSourcePlay();
    
    return true;
  }
  
private:
  bool keepPlaying = true;
  OggSource oggSource;
  ALuint[3] buffers;
  ALuint source;
}
