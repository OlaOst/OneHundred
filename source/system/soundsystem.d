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
    
  ALuint[64] sources;
    
  this()
  {
    super(Aspect.getAspectForAll!(Sound));
  
    DerelictAL.load();
    DerelictOgg.load();
    DerelictVorbis.load();
    DerelictVorbisFile.load();
    
    /*foreach (index; iota(0, sources.length))
    {
      alGenSources(1, &sources[index]);
    }*/
    
    //loadFile("gasturbinestartup.ogg");
    
    alListener3f(AL_POSITION, 0.0, 0.0, 1.0);
    alListener3f(AL_VELOCITY, 0.0, 0.0, 0.0);
    
    auto stream = new AudioStream("orbitalelevator.ogg");
    
    stream.printInfo();
    
    stream.startPlaybackThread();
  }
  
  override void process(Entity entity)
  {
    
  }
  
  void updatestuff()
  {
  }
}
