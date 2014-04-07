module system.soundsystem;

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
import component.sound;
import entity;
import system.system;


final class SoundSystem : System
{
  bool stopPlaying = false;
  Sound[] sounds;
  
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
    return entity.sound !is null;
  }
  
  override void addEntity(Entity entity)
  {
    if (canAddEntity(entity))
    {
      indexForEntity[entity] = sounds.length;
      entityForIndex[sounds.length] = entity;
      
      sounds ~= entity.sound;
    }
  }
  
  override void update()
  {
    foreach (sound; sounds)
    {
      if (stopPlaying)
        sound.stopPlaying();
      else if (!sound.isPlaying)
        sound.startPlaying();        
    }
  }
  
  void silence(Entity entity)
  {
    if (entity in indexForEntity)
    {
      sounds[indexForEntity[entity]].stopPlaying();
    }
  }
  
  void silence()
  {
    stopPlaying = true;
    
    foreach (sound; sounds)
      sound.stopPlaying();
  }
}
