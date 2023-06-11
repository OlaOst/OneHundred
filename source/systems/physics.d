module systems.physics;

import std;

import inmath.linalg;

import accumulatortimer;
import components.input;
import converters;
import entity;
import forcecalculator;
import integrator.integrator;
import integrator.state;
import integrator.states;
import system;


class Physics : System!State
{
  alias components currentStates;
  State[] previousStates;
  AccumulatorTimer timer;

  this()
  {
    timer = new AccumulatorTimer(0.25, 1.0/60.0);
  }

  bool canAddEntity(Entity entity)
  {
    return entity.has("position") && entity.has("mass");
  }

  State makeComponent(Entity entity)
  {
    enforce(entity.get!double("mass") > 0.0,
      "Physics entities need a positive nonzero mass, tried to register entity with mass "
      ~ entity.get!double("mass").to!string);
    return State(entity, &calculateForce, &calculateTorque);
  }

  void updateFromEntities()
  {
    // TODO: we have two separate places that handle forces and torques
    // 1. entity values
    // 2. forcecalculator
    // these should be combined into one stop shop for handling forces
    foreach (size_t index, Entity entity; entityForIndex)
    {
      components[index].position = entity.get!vec3("position");
      components[index].velocity = entity.get!vec3("velocity");
      components[index].force = entity.get!vec3("force");
      components[index].angle = entity.get!double("angle").normalizedAngle;
      components[index].rotation = entity.get!double("rotation");
      components[index].torque = entity.get!double("torque");
      components[index].mass = entity.get!double("mass");

      assert(&components[index]);
    }
  }

  void updateValues() @nogc
  {
    timer.incrementAccumulator();

    previousStates = currentStates;
    double time = timer.currentTime;
    while (timer.accumulator >= timer.timeStep)
    {
      integrateStates(currentStates, previousStates, time, timer.timeStep);
      timer.accumulator -= timer.timeStep;
      time += timer.timeStep;
    }
    interpolateStates(currentStates, previousStates, timer.accumulator / timer.timeStep);
  }

  void updateEntities() //@nogc
  {
    foreach (size_t index, Entity entity; entityForIndex)
    {
      entity["position"] = components[index].position;
      entity["velocity"] = components[index].velocity;
      entity["angle"] = components[index].angle;
      entity["rotation"] = components[index].rotation;

      // reset force and torque for next update
      entity["force"] = vec3(0.0, 0.0, 0.0);
      entity["torque"] = 0.0;

      // keep old values, from forceCalculator
      entity["previousForce"] = components[index].force;
      entity["previousTorque"] = components[index].torque;
    }
  }
}
