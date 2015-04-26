module entityfactory.entitycollection;

import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.stdio;
import std.string;

import entity;
import valueparser;


Entity[string] createEntityCollectionFromFile(string fileName)
{
  string[] lines;
  foreach (string line; fileName.File.lines)
    lines ~= line;

  return lines.createEntityCollection;
}

auto getKeyValues(string[] lines)
{
  return lines.map!(line => line.strip)
              .filter!(line => !line.empty)
              .filter!(line => !line.startsWith("#"))
              .map!(line => line.split("="));
}

Entity[string] createEntityCollection(string[] lines)
{
  string[string][string] keyValuesByFullName;
  
  foreach (keyValue; lines.getKeyValues)
  {
    auto fullKey = keyValue[0].strip.to!string;
    auto keyParts = fullKey.split(".");
    
    string fullName;
    string key;
    
    if (keyParts.canFind("relation"))
    {
      auto parts = keyParts.findSplitBefore(["relation"]);
      
      fullName = parts[0].join('.');
      key = parts[1].join('.');
    }
    else
    {
      fullName = keyParts.array()[0..$-1].join('.');
      key = keyParts.array()[$-1..$].join('.');
    }
    
    auto value = keyValue[1].strip.to!string.parseValue(key);

    keyValuesByFullName[fullName][key] = value;
  }
  
  Entity[string] result;
  
  foreach (fullName, keyValues; keyValuesByFullName)
  {
    keyValues["fullName"] = fullName;
    result[fullName] = new Entity(keyValues);
  }
    
  return result;
}
