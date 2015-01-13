module valueparser;

import std.algorithm;
import std.conv;
import std.file;
import std.math;
import std.random;
import std.range;
import std.string;

import gl3n.linalg;

import converters;


// TODO: common place for these, typemapping.d or something
// or get them by reflecting components
auto immutable vec2Types = ["position", "velocity", "force"];
auto immutable doubleTypes = ["size", "angle", "rotation", "torque"];
auto immutable fileTypes = ["sprite", "sound"];

string parseValue(string value, string key)
{
  auto result = value.replace("PI", PI.to!string);
  
  if (result.canFind("to"))
  {
    if (vec2Types.canFind(key))
    {
      auto from = result.split("to")[0].strip.to!string.myTo!vec2;
      auto to = result.split("to")[1].strip.to!string.myTo!vec2;
      
      result = vec2(uniform(from.x, to.x), uniform(from.y, to.y)).to!string;
    }
    if (doubleTypes.canFind(key))
    {
      auto from = result.split("to")[0].strip.to!string.to!double;
      auto to = result.split("to")[1].strip.to!string.to!double;
      
      result = uniform(from, to).to!string;
    }
  }
  
  if (result.canFind("*") && fileTypes.canFind(key))
  {
    auto fileParts = result.retro.findSplit("/");
    auto pattern = fileParts[0].to!string.retro.to!string;
    auto path = fileParts[2].retro.to!string;
    
    auto files = dirEntries(path, pattern, SpanMode.shallow).
                 map!(dirEntry => dirEntry.name).array();
  
    if (!files.empty)
      result = files.randomSample(1).front;
  }
  
  return result;
}