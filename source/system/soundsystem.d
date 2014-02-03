module system.soundsystem;

import std.conv;
import std.exception;
import std.range;
import std.stdio;

import artemisd.all;
import derelict.openal.al;
import derelict.ogg.ogg;
//import derelict.vorbis.enc;
import derelict.vorbis.file;
import derelict.vorbis.vorbis;

import audio.raw;
import audio.stream;
import component.sound;


final class SoundSystem : EntityProcessingSystem
{
  mixin TypeDecl;
  
  bool stopPlaying = false;
  
  this()
  {
    super(Aspect.getAspectForAll!(Sound));
  
    DerelictAL.load();
    DerelictOgg.load();
    DerelictVorbis.load();
    DerelictVorbisFile.load();
    
    auto device = alcOpenDevice(null);
    auto context = alcCreateContext(device, null);
    alcMakeContextCurrent(context);

    alListener3f(AL_POSITION, 0.0, 0.0, 1.0);
    alListener3f(AL_VELOCITY, 0.0, 0.0, 0.0);
  }
  
  override void process(Entity entity)
  {
    auto sound = entity.getComponent!Sound;
    
    if (sound)
    {
      if (stopPlaying)
        sound.stopPlaying();
      else if (!sound.isPlaying)
        sound.startPlaying();
    }
  }
  
  void silence()
  {
    stopPlaying = true;
  }
}
