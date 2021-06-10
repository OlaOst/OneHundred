module audio.setup;

import std;

import bindbc.openal;
import derelict.ogg.ogg;
import derelict.vorbis;
import loader = bindbc.loader.sharedlib;


void setupAudio()
{
  scope(failure) 
    loader.errors.each!(info => writeln(info.error.to!string, ": ", info.message.to!string));  
    
  auto loadedOpenALSupport = loadOpenAL();
  if (loadedOpenALSupport != ALSupport.al11)
  {
    enforce(loadedOpenALSupport != ALSupport.noLibrary, "Failed to load OpenAL library");
    enforce(loadedOpenALSupport != ALSupport.badLibrary, "Error loading OpenAL library");
  }
  
  DerelictOgg.load();
  DerelictVorbis.load();
  DerelictVorbisFile.load();
  
  auto device = alcOpenDevice(null);
  auto context = alcCreateContext(device, null);
  alcMakeContextCurrent(context);
  
  alListener3f(AL_POSITION, 0.0, 0.0, 10.0);
  alListener3f(AL_VELOCITY, 0.0, 0.0, 0.0);
  alDistanceModel(AL_LINEAR_DISTANCE_CLAMPED);
}
