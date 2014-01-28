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

import audiostream;
import component.sound;


final class SoundSystem : EntityProcessingSystem
{
  mixin TypeDecl;
  
  AudioStream stream;
  
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
    
    stream = new AudioStream("orbitalelevator.ogg");
    
    stream.printInfo();
    
    // TODO: make the thread liston to quit events so we don't have to listen to the end of the music when quitting
    stream.startPlaybackThread();
  }
  
  override void process(Entity entity)
  {
    
  }
  
  void update()
  {
  }
  
  void silence()
  {
    stream.silence();
  }
}
