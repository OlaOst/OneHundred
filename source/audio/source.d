module audio.source;

import std;

import bindbc.openal;
import gl3n.linalg;


interface Source
{
  void play();
  void silence();
  bool isPlaying();
  
  ALuint getAlSource();
}

void check()
{
  auto error = alGetError();
  enforce(error == AL_NO_ERROR, "OpenAL error " ~ enumMapping[error]);
}

bool isPlaying(ALuint source)
{
  ALenum state;
  source.alGetSourcei(AL_SOURCE_STATE, &state);
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

enum auto enumNames = getEnumNames!(__traits(derivedMembers, bindbc.openal.types));
enum auto enumValues = getEnumValues!enumNames;
static immutable string[ALenum] enumMapping;

shared static this()
{
  string[ALenum] temp;
  foreach (index, enumName; enumNames)
  {
    temp[enumValues[index]] = enumName;
  }
  
  enumMapping = assumeUnique(temp);
}
