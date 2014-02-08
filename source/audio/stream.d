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


// this code made possible by http://devmaster.net/posts/openal-lesson-8-oggvorbis-streaming-using-the-source-queue
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
  
  // stop thread playing sound (via playbackLoop delegate)
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

bool stream(ALuint buffer, ref OggSource oggSource)
{
  enum int bufferSize = 32768;
  int size = 0;
  int section;
  long bytesRead;
  byte[bufferSize] data;
  
  while (size < bufferSize)
  {
    bytesRead = ov_read(&oggSource.oggFile, data.ptr + size, bufferSize - size, 0, 2, 1, &section);
    
    enforce(bytesRead >= 0, "Error streaming Ogg file: " ~ bytesRead.to!string);
    
    if (bytesRead > 0)
      size += bytesRead;
    else
      break;
  }
  
  if (size == 0)
    return false;

  alBufferData(buffer, oggSource.format, data.ptr, size, oggSource.info.rate);
  check();
  
  return true;
}
