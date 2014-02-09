module audio.oggsource;

import std.algorithm;
import std.conv;
import std.exception;
import std.stdio;

import derelict.openal.al;
import derelict.ogg.ogg;
import derelict.vorbis.vorbis;
import derelict.vorbis.file;

import audio.source;


struct OggSource
{
  File file;
  OggVorbis_File oggFile;  
  vorbis_comment comment;
  vorbis_info info;
  ALenum format;

  this(string fileName)
  {
    file = File(fileName);
    enforce(fileName.endsWith(".ogg"), 
            "Can only stream ogg files, " ~ fileName ~ " is not recognized as an ogg file.");

    auto result = ov_open(file.getFP(), &oggFile, null, 0);
    enforce(result == 0, "Error opening Ogg stream: " ~ result.to!string);
    
    this.oggFile = oggFile;
    info = *ov_info(&oggFile, -1);
    comment = *ov_comment(&oggFile, -1);
    format = (info.channels == 1) ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;
  }
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
    bytesRead = ov_read(&oggSource.oggFile, data.ptr + size, bufferSize-size, 0, 2, 1, &section);
    
    enforce(bytesRead >= 0, "Error streaming Ogg file: " ~ bytesRead.to!string);
    
    if (bytesRead > 0)
      size += bytesRead;
    else
      break;
  }
  
  if (size == 0)
    return false;

  buffer.alBufferData(oggSource.format, data.ptr, size, oggSource.info.rate);
  check();
  
  return true;
}
