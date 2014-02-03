module audio.raw;

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


class Raw : Source
{
public:
  this(string fileName)
  {
    writeln("creating raw from ", fileName);
    
    enforce(fileName.endsWith(".wav"), "Can only read wav soundfiles, " ~ filename ~ " is not recognized as a wav file");
  
    this.filename = fileName;
    file = File(fileName);
    
    ushort channels;
    ushort bits;
    uint size;
    
    ubyte[] data;
    
    auto chunks = file.byChunk(4096);
    
    if (!chunks.empty)
    {
      auto first = chunks.front;
      
      enforce(first.length >= 44, "Problem parsing wav file header, is " ~ fileName ~ " really a wav file?");
      
      enforce(first[0..4] == "RIFF", "Problem parsing wav file header, is " ~ fileName ~ " really a wav file?");
      // skip size value (4 bytes)
      enforce(first[8..12] == "WAVE", "Problem parsing wav file header, is " ~ fileName ~ " really a wav file?");
      // skip "fmt", format length, format tag (10 bytes)
      channels = (cast(ushort[])first[22..24])[0];
      frequency = (cast(ALsizei[])first[24..28])[0];
      // skip average bytes per second, block align, bytes by capture (6 bytes)
      bits = (cast(ushort[])first[34..36])[0];
      // skip 'data' (4 bytes)
      size = (cast(uint[])first[40..44])[0];
      
      data ~= first[44..$].dup;
      
      chunks.popFront;
    }
    
    foreach (ubyte[] chunk; chunks)
    {
      data ~= chunk.dup;
      
      enforce(data.length < 4194304, "wav file too large, try a smaller wav or an ogg file instead, or wait for wav streaming support");
    }
    
    enforce(data.length == size, "Mismatch in data size read from wav file vs what wav file said the size should be");

    alGenBuffers(1, &buffer);
    enforce(alIsBuffer(buffer));
    
    check();
    
    alBufferData(buffer, channels == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16, data.ptr, data.length, frequency);
    
    check();
  }
  
  void play()
  {
    // find a source not currently playing
    //auto foundSource = Source.sources.filter!(source => !source.isPlaying);
    source = 0;
    //debug writeln("checking ", Source.sources.length, " sources");
    foreach (ref checkSource; Source.sources)
    {
      //debug writeln("checking source ", checkSource, ", alIsSource: ", checkSource.alIsSource, ", isplaying: ", checkSource.isPlaying);
      
      if (!checkSource.alIsSource)
      {
        alGenSources(1, &checkSource);
        //writeln("genning source ", checkSource);
        check();
      }
      
      if (!checkSource.isPlaying)
      {
        //writeln("found nonplaying source ", checkSource);
        
        source = checkSource;
        break;
      }
    }
    
    if (source.alIsSource)
    {
      //alGenSources(1, &source);
      enforce(source.alIsSource);
      
      check();
    
      //auto source = foundSource.front;
    
      source.alSourceQueueBuffers(1, &buffer);
      source.alSourcePlay;
    }
    else
    {
      //writeln("no free sound sources");
    }
  }
  
  void silence()
  {
    enforce(alIsSource(source));
    alSourceUnqueueBuffers(source, 1, &buffer);
  }
  
private:
  string filename;
  File file;
  ALsizei frequency;
    
  ALenum format;
 
  ALuint buffer;
  ALuint source;
}
