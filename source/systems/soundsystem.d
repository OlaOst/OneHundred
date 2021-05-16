module systems.soundsystem;

import std;

import bindbc.openal;
import derelict.ogg.ogg;
import derelict.vorbis;
import loader = bindbc.loader.sharedlib;

import audio.raw;
import audio.source;
import audio.stream;
import components.sound;
import entity;
import system;


final class SoundSystem : System!Sound
{
  bool stopPlaying = false;
  Source[string] sourceCache;
  ALuint[32] sources;
  
  this()
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
  
  public ALuint findFreeSource()
  {    
    // find a source not currently playing
    foreach (ref source; sources)
    {
      if (source <= 0 || !source.alIsSource)
      {
        alGenSources(1, &source);
        enforce(source.alIsSource);
        check();
        return source;
      }
      
      if (!source.isPlaying() && !source.isPending())
      {
        return source;
      }
    }
    return 0;
  }
  
  bool canAddEntity(Entity entity)
  {
    return entity.has("sound");
  }
  
  Sound makeComponent(Entity entity)
  {
    auto fileName = entity.get!string("sound");
    
    if (fileName !in sourceCache)
    {
      if (fileName.endsWith(".wav"))
        sourceCache[fileName] = new Raw(fileName, this);
        
      if (fileName.endsWith(".ogg"))
        sourceCache[fileName] = new Stream(fileName, this);
    }
    
    auto sound = new Sound(sourceCache[fileName]);
        
    return sound;
  }
  
  void updateValues()
  {
    foreach (sound; components)
    {
      if (stopPlaying)
        sound.stopPlaying();
      else if (!sound.isPlaying)
        sound.startPlaying();
    }
  }
  
  void updateEntities() {}
  
  void updateFromEntities()
  {
  }
  
  void silence(Entity entity)
  {
    if (entity in indexForEntity)
    {
      components[indexForEntity[entity]].stopPlaying();
      entity["ToBeRemoved"] = true;
    }
  }
  
  void silence()
  {
    stopPlaying = true;
    
    foreach (sound; components)
      sound.stopPlaying();
  }
  
  override void close()
  {
    silence();
  }
}
