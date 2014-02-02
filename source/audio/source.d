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
  
  final void check()
  {
    auto error = alGetError();
    
    enforce(error == AL_NO_ERROR, "OpenAL error " ~ enumMapping[error]);
  }
}
  
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
