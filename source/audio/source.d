module audio.source;

import std.algorithm;
import std.conv;
import std.exception;
import std.traits;

import derelict.openal.al;


interface Source
{
  void play();
  void silence();
  
  static ALuint[32] sources;
  
  static ALuint findFreeSource()
  {
    // find a source not currently playing
    foreach (ref source; sources)
    {
      if (!source.alIsSource)
      {
        alGenSources(1, &source);
        enforce(source.alIsSource);
        check();
      }
      
      if (!source.isPlaying)
        return source;
    }
    return 0;
  }
}

void check()
{
  auto error = alGetError();
  enforce(error == AL_NO_ERROR, "OpenAL error " ~ enumMapping[error]);
}

bool isPlaying(ALuint source)
{
  ALenum state;
  alGetSourcei(source, AL_SOURCE_STATE, &state);
  
  return state == AL_PLAYING;
}


// the stuff below is for getting error names printed out instead of error codes
// since the derelict openal enums are anonymous there is no way to get them directly...
template tuple(args...)
{
  alias tuple = args;
}

template getEnumNames(args...)
{
  static if (args.length > 0)
  {
    static if (args[0].startsWith("AL_"))
      alias getEnumNames = tuple!(args[0], getEnumNames!(args[1..$]));
    else
      alias getEnumNames = getEnumNames!(args[1..$]);
  }
  else
  {
    alias getEnumNames = args;
  }
}

template getEnumValues(args...)
{
  static if (args.length > 0)
    alias getEnumValues = tuple!(cast(ALenum)mixin(args[0]), getEnumValues!(args[1..$]));
  else
    alias getEnumValues = args;
}

enum auto enumNames = getEnumNames!(__traits(derivedMembers, derelict.openal.al));
enum auto enumValues = getEnumValues!enumNames;
static immutable string[ALenum] enumMapping;

static this()
{
  string[ALenum] temp;
  foreach (index, enumName; enumNames)
  {
    temp[enumValues[index]] = enumName;
  }
  
  enumMapping = assumeUnique(temp);
}
