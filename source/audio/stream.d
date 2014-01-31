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


// this code made possible by http://devmaster.net/posts/openal-lesson-8-oggvorbis-streaming-using-the-source-queue
class Stream
{
public:
  this(string filename)
  {
    this.filename = filename;
    file = File(filename);
    
    enforce(filename.endsWith(".ogg"), "Can only stream ogg files, " ~ filename ~ " is not recognized as an ogg file.");

    auto result = ov_open(file.getFP(), &oggFile, null, 0);
  
    enforce(result == 0, "Error opening Ogg stream: " ~ result.to!string);
  
    info = *ov_info(&oggFile, -1);
    comment = *ov_comment(&oggFile, -1);
  
    format = (info.channels == 1) ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;

    alGenBuffers(buffers.length, buffers.ptr);
    foreach (buffer; buffers)
      enforce(alIsBuffer(buffer));
    
    check();
    
    alGenSources(1, &source);
    enforce(alIsSource(source));
    
    check();
  }
  
  void startPlaybackThread()
  {
    auto playbackTask = task(&this.playbackLoop);
    
    playbackTask.executeInNewThread();
  }
  
  void printInfo()
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
    {
      writeln("  " ~ comment.user_comments[i].to!string);
    }
  }
  
  // stop thread playing sound (via playbackLoop delegate)
  void silence()
  {
    keepPlaying = false;
  }
  
  bool keepPlaying = true;
  
  
private:
  void playbackLoop()
  {
    while (update() && keepPlaying)
    {
      if (!playing())
      {
        enforce(playback(), "Ogg abruptly stopped");
        
        //writeln("Ogg stream interrupted");
      }
    }
  }
  
  bool update()
  {
    int buffersProcessed;
    bool active = true;
    
    alGetSourcei(source, AL_BUFFERS_PROCESSED, &buffersProcessed);
    
    while (buffersProcessed--)
    {
      ALuint buffer;
      
      alSourceUnqueueBuffers(source, 1, &buffer);
      check();
      
      active = stream(buffer);
      
      if (active)
        alSourceQueueBuffers(source, 1, &buffer);
        
      check();
    }
    
    return active;
  }
  
  bool playing()
  {
    ALenum state;
    alGetSourcei(source, AL_SOURCE_STATE, &state);
    
    return state == AL_PLAYING;
  }
  
  bool playback()
  {
    if (playing())
      return true;
    
    foreach (buffer; buffers)
    {
      if (stream(buffer) == false)
        return false;
    }
    
    alSourceQueueBuffers(source, buffers.length, buffers.ptr);
    alSourcePlay(source);
    
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
  
  void check()
  {
    int error = alGetError();
    enforce(error == AL_NO_ERROR, "OpenAL error " ~ to!string(error));
  }
  
  
private:
  immutable enum int bufferSize = 32768;

  string filename;
  File file;
  OggVorbis_File oggFile;
  
  vorbis_info info;
  vorbis_comment comment;

  ALenum format;
 
  ALuint[3] buffers;
  ALuint source;
}
