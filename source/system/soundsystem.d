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
  
  Stream stream;
  Raw raw;
  //Entity[] entities;
  
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
    
    stream = new Stream("orbitalelevator.ogg");
    stream.printInfo();
    stream.startPlaybackThread();
    
    raw = new Raw("bounce.wav");
    raw.play();
  }
  
  override void process(Entity entity)
  {
    auto sound = entity.getComponent!Sound;
    
    if (sound)
    {
      //entities ~= entity;
      
    }
  }
  
  void update()
  {
  }
  
  void silence()
  {
    if (stream !is null)
      stream.silence();
  }
}
