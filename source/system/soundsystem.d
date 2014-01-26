module system.soundsystem;

import artemisd.all;

import component.sound;


final class SoundSystem : EntityProcessingSystem
{
  mixin TypeDecl;
    
  this()
  {
    super(Aspect.getAspectForAll!(Sound));
  }
  
  override void process(Entity entity)
  {
    
  }
  
  void update()
  {
  }
}
