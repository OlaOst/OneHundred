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

import audio.source;

// this code made possible by http://devmaster.net/posts/openal-lesson-8-oggvorbis-streaming-using-the-source-queue
class Stream : Source
{
public:
  this(string filename)
  {
    file = File(filename);
    enforce(filename.endsWith(".ogg"), "Can only stream ogg files, " ~ filename ~ " is not recognized as an ogg file.");

    auto result = ov_open(file.getFP(), &oggFile, null, 0);
    enforce(result == 0, "Error opening Ogg stream: " ~ result.to!string);
  
    info = *ov_info(&oggFile, -1);
    comment = *ov_comment(&oggFile, -1);
    format = (info.channels == 1) ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;

    alGenBuffers(buffers.length, buffers.ptr);
    foreach (buffer; buffers)
      enforce(buffer.alIsBuffer);
    
    source = Source.findFreeSource();
    check();
  }
  
  void printInfo(vorbis_info info)
  {
    writeln("version:         " ~ info._version.to!string);
    writeln("channels:        " ~ info.channels.to!string);
    writeln("rate (hz):       " ~ info.rate.to!string);
    writeln("bitrate upper:   " ~ info.bitrate_upper.to!string);
    writeln("bitrate nominal: " ~ info.bitrate_nominal.to!string);
    writeln("bitrate lower:   " ~ info.bitrate_lower.to!string);
    writeln("bitrate window:  " ~ info.bitrate_window.to!string);
    writeln("vendor:          " ~ comment.vendor.to!string);
    
    writeln("comments: ");
    for (int i = 0; i < comment.comments; i++)
      writeln("  " ~ comment.user_comments[i].to!string);
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
    {
      if (!source.isPlaying)
      {
        enforce(playback(), "Ogg abruptly stopped");
      }
    }
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
      
      isActive = stream(buffer);
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
    
    if (buffers[].any!(buffer => !stream(buffer)))
      return false;
    
    source.alSourceQueueBuffers(buffers.length, buffers.ptr);
    source.alSourcePlay();
    
    return true;
  }
  
  bool stream(ALuint buffer)
  {
    int size = 0;
    int section;
    long bytesRead;
    byte[bufferSize] data;
    
    while (size < bufferSize)
    { 
      bytesRead = ov_read(&oggFile, data.ptr + size, bufferSize - size, 0, 2, 1, &section);
      
      enforce(bytesRead >= 0, "Error streaming Ogg file: " ~ bytesRead.to!string);
      
      if (bytesRead > 0)
        size += bytesRead;
      else
        break;
    }
    
    if (size == 0)
      return false;

    alBufferData(buffer, format, data.ptr, size, info.rate);
    check();
    
    return true;
  }  
  
private:
  immutable enum int bufferSize = 32768;

  bool keepPlaying = true;
  File file;
  OggVorbis_File oggFile;  
  vorbis_comment comment;
  vorbis_info info;  
  ALenum format;
  ALuint[3] buffers;
  ALuint source;
}
