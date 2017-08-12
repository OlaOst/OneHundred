module audio.raw;

import std.algorithm;
import std.exception;
import std.stdio;

import derelict.ogg.ogg;
import derelict.vorbis;
import derelict.openal.al;

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
    
    debug if (data.length != size)
      writeln("Read ", data.length, " bytes from wav file, but wav header said it contained "
                     , size, " bytes");
    //enforce(data.length == size, "Mismatch in data size read from wav file vs " ~
    //                             "what wav file said the size should be");

    alGenBuffers(1, &buffer);
    enforce(buffer.alIsBuffer);
    buffer.alBufferData(channels == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16, 
                        data.ptr, cast(int)data.length, frequency);
  }
  
  void play()
  {
    source = Source.findFreeSource();
  
    if (source > 0 && source.alIsSource)
    {
      source.alSourcei(AL_BUFFER, buffer);
      source.alSourcePlay();
    }
  }
  
  bool isPlaying()
  {
    if (source > 0 && source.alIsSource)
    {
      return source.isPlaying();
    }
    return false;
  }
  
  void silence()
  {
    if (source > 0)
    {
      enforce(source.alIsSource);
      source.alSourceStop();
    }
  }
  
  ALuint getAlSource() { return source; }
  
private:
  File file;
  ALsizei frequency;
  ALenum format; 
  ALuint buffer;
  ALuint source;
}
