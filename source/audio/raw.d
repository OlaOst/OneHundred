module audio.raw;

import std.algorithm;
import std.conv;
import std.exception;
import std.stdio;

import derelict.ogg.ogg;
import derelict.vorbis.vorbis;
import derelict.vorbis.file;
import derelict.openal.al;

import audio.source;


class Raw : Source
{
invariant()
{
  check();
}
public:
  this(string fileName)
  {
    enforce(fileName.endsWith(".wav"), 
            "Can only read wav soundfiles, " ~ fileName ~ " is not recognized as a wav file");
  
    file = File(fileName);
    ushort channels;
    uint size;
    ubyte[] data;
    auto chunks = file.byChunk(4096);
    
    if (!chunks.empty)
    {
      auto first = chunks.front;
      
      enforce(first.length >= 44, 
              "Problem parsing wav file header, is " ~ fileName ~ " really a wav file?");
      enforce(first[0..4] == "RIFF", 
              "Problem parsing wav file header, is " ~ fileName ~ " really a wav file?");
      // skip size value (4 bytes)
      enforce(first[8..12] == "WAVE", 
              "Problem parsing wav file header, is " ~ fileName ~ " really a wav file?");
      // skip "fmt", format length, format tag (10 bytes)
      channels = (cast(ushort[])first[22..24])[0];
      frequency = (cast(ALsizei[])first[24..28])[0];
      // skip average bytes per second, block align, bytes by capture (6 bytes)
      ushort bits = (cast(ushort[])first[34..36])[0];
      // skip 'data' (4 bytes)
      size = (cast(uint[])first[40..44])[0];
      data ~= first[44..$].dup;
      
      chunks.popFront;
    }
    
    foreach (ubyte[] chunk; chunks)
    {
      data ~= chunk.dup;
      enforce(data.length < 4194304, "wav file too large, " ~
                                     "try a smaller wav or an ogg file instead, " ~
                                     "or wait for wav streaming support");
    }
    
    enforce(data.length == size, "Mismatch in data size read from wav file vs " ~
                                 "what wav file said the size should be");

    alGenBuffers(1, &buffer);
    enforce(buffer.alIsBuffer);
    buffer.alBufferData(channels == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16, 
                        data.ptr, data.length, frequency);
  }
  
  void play()
  {
    source = Source.findFreeSource();
    
    if (source.alIsSource)
    {
      source.alSourceQueueBuffers(1, &buffer);
      source.alSourcePlay;
    }
  }
  
  void silence()
  {
    enforce(source.alIsSource);
    source.alSourceUnqueueBuffers(1, &buffer);
  }
  
private:
  File file;
  ALsizei frequency;
  ALenum format; 
  ALuint buffer;
  ALuint source;
}
