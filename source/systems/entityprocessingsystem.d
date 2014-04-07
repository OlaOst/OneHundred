module EntityProcessingSystem;

import std.algorithm;
import std.range;
import std.stdio;

import gl3n.linalg;


unittest
{
  auto test = new MovementSystem();
  
  auto entity = new Entity;
  entity.addComponent(new Position(vec2(0.0, 0.5)));
  entity.addComponent(new Velocity(vec2(0.5, 0.0)));
  test.addEntity(entity);
  
  test.update();
  
  assert(entity.getComponent!Position.position == vec2(0.5, 0.5));
}

class Component
{
  string typeName;
}

class Position : Component
{
  this(vec2 position)
  {
    typeName = "Position";
    this.position = position;
  }
  
  vec2 position;
  alias position this;
}

class Velocity : Component
{
  this(vec2 velocity)
  {
    typeName = "Velocity";
    this.velocity = velocity;
  }
  
  vec2 velocity;
  alias velocity this;
}

mixin template ComponentForEntity(ComponentType)
{
  ComponentType[Entity] ComponentForEntity;
}

mixin ComponentForEntity!Position;
mixin ComponentForEntity!Velocity;

ComponentType getComponentForEntity(ComponentType)(Entity entity)
{
  return componentsForEntity[ComponentType.stringof][entity];
}

class Entity
{
  int id;
  Component[string] componentsByTypeName;
  
  void addComponent(Component component)
  {
    componentsByTypeName[component.typeName] = component;
  }
  
  ComponentType getComponent(ComponentType)() //(string componentType)
  {
    return ComponentType;
  }
}

abstract class EntityProcessingSystem
{
  protected this(string[] necessaryComponentTypes)
  {
    this.necessaryComponentTypes = necessaryComponentTypes;
  }
  
  void addEntity(Entity entity)
  {
    bool entityHasNecessaryComponents = true;
    
    foreach (necessaryComponentType; necessaryComponentTypes)
    {
      if (necessaryComponentType !in entity.componentsByTypeName)
      {
        entityHasNecessaryComponents = false;
        break;
      }
      else
      {
        indexForEntityForComponentType[necessaryComponentType][entity] = entity.id;
      }
    }
    
    if (entityHasNecessaryComponents)
      entities ~= entity;
  }
  
  void update();
  
  string[] necessaryComponentTypes;
  Entity[] entities;
  
  int[Entity][string] indexForEntityForComponentType;
}

struct Movement
{
  this(vec2[] positions, vec2[] velocities, double timeStep)
  {
    this.positions = positions;
    this.velocities = velocities;
    this.timeStep = timeStep;
  }
  
  bool empty()
  {
    return index < positions.length;
  }
  
  vec2 front()
  {
    return positions[index] + velocities[index] * timeStep;
  }
  
  void popFront()
  {
    index++;
  }
  
  int index = 0;
  
  vec2[] positions;
  vec2[] velocities;
  double timeStep;
}

vec2[] move(vec2[] positions, vec2[] velocities, double timeStep)
{
  return zip(positions, velocities).map!(posvel => posvel[0] + posvel[1] * timeStep).array;
}

// value arrays - all positions in one array separate from systems and entities
// each array needs a mapping from entity to index so one can get for example the position of a given entity
// option 1: arrays are shuffled so systems can iterate over them while minimizing jumps/skips (movement system needs to skip all positions whose mapped entity does not also map to a velocity)
// option 2: all systems have their own copy of their needed arrays. they need to copy values between themselves to stay up to date.

class MovementSystem : EntityProcessingSystem
{
  this()
  {
    super(["Position", "Velocity"]);
  }
  
  override void update()
  {
    writeln("mov updating ", entities.length, " entities");
    foreach (Entity entity; entities)
    {
      //vec2 pos = entity.Position;
      //pos += entity.Velocity;
      //entity.Position = pos;
      
      //writeln(entity.Position);
    }
    
    assert(positions.length == velocities.length);
    
    foreach (int index; iota(0, positions.length))
    {
      positions[index] += velocities[index];
    }
  }
  
  vec2[] positions;
  vec2[] velocities;
}

class World
{
  void addSystem(EntityProcessingSystem system)
  {
    systems ~= system;
  }
  
  void addEntity(Entity entity)
  {
    foreach (system; systems)
    {
      system.addEntity(entity);
    }
  }
  
  private EntityProcessingSystem[] systems;
}