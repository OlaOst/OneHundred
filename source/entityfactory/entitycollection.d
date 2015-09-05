module entityfactory.entitycollection;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.range;
import std.stdio;
import std.string;

import entity;
import valueparser;


Entity[string] createEntityCollectionFromFile(string fileName)
{
  return createKeyValueCollectionFromFile(fileName).createEntityCollection;
}

string[string][string] createKeyValueCollectionFromFile(string fileName, string[] previouslyLoadedFiles = [])
{
  enforce(!previouslyLoadedFiles.canFind(fileName), "Circular reference detected, tried to load " ~ fileName ~ " with previously loaded files " ~ previouslyLoadedFiles.to!string);
  
  string[] lines;
  foreach (string line; fileName.File.lines)
    lines ~= line;

  return lines.createKeyValueCollection(previouslyLoadedFiles ~ fileName);
}

auto getKeyValues(string[] lines)
{
  return lines.map!(line => line.strip)
              .filter!(line => !line.empty)
              .filter!(line => !line.startsWith("#"))
              .map!(line => line.split("="));
}

string[string][string] createKeyValueCollection(string[] lines, string[] previouslyLoadedFiles)
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
  
  string[string][string] allSourceKeyValuesByFullName;
  // expand values
  foreach (fullName, keyValues; keyValuesByFullName)
  { 
    if ("source" in keyValues)
    {
      auto source = keyValues["source"];
      
      auto sourceKeyValuesByFullName = source.createKeyValueCollectionFromFile(previouslyLoadedFiles);
      
      foreach (sourceFullName, sourceKeyValues; sourceKeyValuesByFullName)
      {
        auto expandedFullName = (sourceFullName.length > 0) ? join([fullName, sourceFullName], ".") : fullName;
        allSourceKeyValuesByFullName[expandedFullName] = sourceKeyValues;
      }
    }
  }
  
  foreach (sourceFullName, sourceKeyValues; allSourceKeyValuesByFullName)
  {
    foreach (key, value; sourceKeyValues)
    {
      if (key !in keyValuesByFullName[sourceFullName])
        keyValuesByFullName[sourceFullName][key] = value;
    }
  }
  
  return keyValuesByFullName;
}

Entity[string] createEntityCollection(string[string][string] keyValuesByFullName)
{
  Entity[string] result;
  
  foreach (fullName, keyValues; keyValuesByFullName)
  {
    keyValues["fullName"] = fullName;
    result[fullName] = new Entity(keyValues);
  }
  
  return result;
}
