module systems.soundsystem;

import std;

import bindbc.openal;
import derelict.ogg.ogg;
import derelict.vorbis;
import loader = bindbc.loader.sharedlib;

import audio.raw;
import audio.setup;
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
    setupAudio();
  }
  
  public ALuint findFreeSource()
  {    
    // return first source not currently playing
    foreach (ref source; sources)
    {
      if (source <= 0 || !source.alIsSource)
      {
        alGenSources(1, &source);
        return source;
      }
      if (!source.isPlaying() && !source.isPending())
        return source;
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
    return new Sound(sourceCache[fileName]);
  }
  
  void updateValues(bool paused)
  {
    if (stopPlaying)
      components.each!(sound => sound.stopPlaying());
    else 
      components.filter!(sound => !sound.isPlaying).each!(sound => sound.startPlaying());
  }
  
  void updateEntities() {}
  void updateFromEntities() {}
  
  void silence(Entity entity)
  {
    if (entity in indexForEntity)
    {
      components[indexForEntity[entity]].stopPlaying();
      entity["ToBeRemoved"] = true;
    }
  }
  
  override void close()
  {
    stopPlaying = true;
    components.each!(sound => sound.stopPlaying());
  }
}
