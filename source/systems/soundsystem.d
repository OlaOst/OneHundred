module systems.soundsystem;

import std.conv;
import std.exception;
import std.range;
import std.stdio;

import derelict.openal.al;
import derelict.ogg.ogg;
//import derelict.vorbis.enc;
import derelict.vorbis.file;
import derelict.vorbis.vorbis;

import audio.raw;
import audio.stream;
import components.sound;
import entity;
import system;


final class SoundSystem : System!Sound
{
  bool stopPlaying = false;
  
  this()
  {
    DerelictAL.load();
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
  
  override bool canAddEntity(Entity entity)
  {
    return ("sound" in entity.values) !is null;
  }
  
  override Sound makeComponent(Entity entity)
  {
    return new Sound(entity.get!string("sound"));
  }
  
  override void updateValues()
  {
    foreach (sound; components)
    {
      if (stopPlaying)
        sound.stopPlaying();
      else if (!sound.isPlaying)
        sound.startPlaying();        
    }
  }
  
  override void updateEntities()
  {
  }
  
  override void updateFromEntities()
  {
  }
  
  void silence(Entity entity)
  {
    if (entity in indexForEntity)
    {
      components[indexForEntity[entity]].stopPlaying();
      entity.values["ToBeRemoved"] = true.to!string;
    }
  }
  
  void silence()
  {
    stopPlaying = true;
    
    foreach (sound; components)
      sound.stopPlaying();
  }
}
