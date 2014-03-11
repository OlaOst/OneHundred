module entityfactory.tests;

import std.algorithm;
import std.random;
import std.range;
import std.stdio;

import artemisd.all;
import gl3n.linalg;

import component.collider;
import component.drawables.polygon;
import component.drawables.text;
import component.input;
import component.mass;
import component.position;
import component.size;
import component.sound;
import component.velocity;


Entity createMusic(World world)
{
  Entity entity = world.createEntity();
  entity.addComponent(new Sound("audio/orbitalelevator.ogg"));
  entity.addComponent(new Position(vec2(300.0, 0.0), 0.0));
  entity.addComponent(new Velocity(vec2(0.0, 3.0), 0.0));
  entity.addComponent(new Size(0.1));
  entity.addComponent(new Mass(0.1 + 0.1 ^^ 2));
  
  return entity;
}

Entity createStartupSound(World world)
{
  Entity startupSound = world.createEntity();
  startupSound.addComponent(new Sound("audio/gasturbinestartup.ogg"));
  return startupSound;
}

Entity createText(World world)
{
  Entity text = world.createEntity();  
  text.addComponent(new Position(vec2(-1.0, 0.0), 0.0));
  text.addComponent(new Text(0.1, "hello,\n world", vec4(1.0, 1.0, 1.0, 0.0)));
  text.addComponent(new Size(0.1));
  return text;
}
