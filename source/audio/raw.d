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


class Raw
{
public:
  this(string filename)
  {
    enforce(filename.endsWith(".wav"), "Can only read wav soundfiles, " ~ filename ~ " is not recognized as a wav file");
  
    this.filename = filename;
    file = File(filename);
    
    ushort channels;
    ushort bits;
    uint size;
    
    ubyte[] data;
    
    auto chunks = file.byChunk(4096);
    
    if (!chunks.empty)
    {
      auto first = chunks.front;
      
      enforce(first[0..4] == "RIFF");
      // skip size value (4 bytes)
      enforce(first[8..12] == "WAVE");
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
    
    alGenSources(1, &source);
    enforce(alIsSource(source));
    
    check();
    
    alBufferData(buffer, channels == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16, data.ptr, data.length, frequency);
    
    check();
  }
  
  void play()
  {
    alSourceQueueBuffers(source, 1, &buffer);
    alSourcePlay(source);
  }
  
private:
  void check()
  {
    int error = alGetError();
    enforce(error == AL_NO_ERROR, "OpenAL error " ~ to!string(error));
  }
  
  
private:
  string filename;
  File file;
  ALsizei frequency;
    
  ALenum format;
 
  ALuint buffer;
  ALuint source;
}
