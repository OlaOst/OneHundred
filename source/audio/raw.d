module audio.raw;

import std.algorithm;
import std.conv;
import std.exception;
import std.stdio;

import derelict.ogg.ogg;
import derelict.vorbis.vorbis;
import derelict.vorbis.file;
import derelict.openal.al;
import gl3n.linalg;

import audio.source;
import audio.wavheader;


class Raw : Source
{
invariant() { check(); }

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

      parseWavHeader(first, channels, frequency, size);

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
      source.alSource3f(AL_POSITION, position.x, position.y, 0.0);
      source.alSourceQueueBuffers(1, &buffer);
      source.alSourcePlay;
    }
  }
  
  void silence()
  {
    enforce(source.alIsSource);
    source.alSourceUnqueueBuffers(1, &buffer);
  }
  
  void setPosition(vec2 position)
  {
    this.position = position;
  }
  
private:
  File file;
  ALsizei frequency;
  ALenum format; 
  ALuint buffer;
  ALuint source;
  vec2 position;
}
