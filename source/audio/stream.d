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
import gl3n.linalg;

import audio.oggsource;
import audio.source;


class Stream : Source
{
invariant()
{
  check();
}

public:
  this(string fileName)
  {
    oggSource = OggSource(fileName);

    alGenBuffers(buffers.length, buffers.ptr);
    // this line gives compiler error 'exit code -11' on mac
    // see OneHundred-minify.reduced for details
    //enforce(buffers[].all!(buffer => buffer.alIsBuffer));
    foreach (buffer; buffers)
    {
      enforce(buffer.alIsBuffer);
    }
  }
  
  void play()
  {
    auto playbackTask = task(&this.playbackLoop);
    playbackTask.executeInNewThread();
  }
  
  void silence() { keepPlaying = false; }
  ALuint getAlSource() { return source; }
  
private:
  void playbackLoop()
  {
    if ((source = Source.findFreeSource()).alIsSource)
    {
      while (update() && keepPlaying)
        if (!source.isPlaying)
          enforce(playback(), "Ogg abruptly stopped");
    }
    else debug writeln(alIsSource, "Could not get free audio source for stream");
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
      isActive = buffer.stream(oggSource);
      if (isActive)
        source.alSourceQueueBuffers(1, &buffer);
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
