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
  return createKeyValuesCollectionFromFile(fileName).createEntityCollection;
}

string[string][string] createKeyValuesCollectionFromFile(string fileName, 
                                                         string[] previouslyLoadedFiles = [])
{
  enforce(!previouslyLoadedFiles.canFind(fileName), "Circular reference detected, tried to load " 
                                                    ~ fileName ~ " with previously loaded files " 
                                                    ~ previouslyLoadedFiles.to!string);
  
  string[] lines;
  foreach (string line; fileName.File.lines)
    lines ~= line;

  return lines.createKeyValuesCollection(previouslyLoadedFiles ~ fileName);
}

auto getKeyValues(string[] lines)
{
  return lines.map!(line => line.strip)
              .filter!(line => !line.empty)
              .filter!(line => !line.startsWith("#"))
              .map!(line => line.split("="));
}

string[string][string] createKeyValuesCollection(string[] lines, string[] previouslyLoadedFiles)
{
  string[string][string] keyValuesByFullName;
  
  foreach (keyValue; lines.getKeyValues)
  {
    auto fullKey = keyValue[0].strip.to!string;
    auto keyParts = fullKey.split(".");
    auto fullName = keyParts.array()[0..$-1].join('.');
    auto key = keyParts.array()[$-1..$].join('.');
    
    if (keyParts.canFind("relation"))
    {
      auto parts = keyParts.findSplitBefore(["relation"]);
      fullName = parts[0].join('.');
      key = parts[1].join('.');
    }
    
    keyValuesByFullName[fullName][key] = keyValue[1].strip.to!string.parseValue(key);
  }
  
  string[string][string] allSourceKeyValuesByFullName;
  // expand values
  foreach (fullName; keyValuesByFullName.byKey.filter!(fullName => 
                                                        "source" in keyValuesByFullName[fullName]))
  { 
    auto keyValues = keyValuesByFullName[fullName];
    auto sourceKeyValuesByFullName = 
      keyValues["source"].createKeyValuesCollectionFromFile(previouslyLoadedFiles);
    
    foreach (sourceFullName, sourceKeyValues; sourceKeyValuesByFullName)
    {
      auto expandedFullName = (sourceFullName.length > 0) ? join([fullName, sourceFullName], ".")
                                                          : fullName;
      allSourceKeyValuesByFullName[expandedFullName] = sourceKeyValues;
    }
  }
  
  foreach (sourceName, sourceKeyValues; allSourceKeyValuesByFullName)
  {
    sourceKeyValues.byKey.filter!(key => key !in keyValuesByFullName[sourceName])
                         .each!(key => keyValuesByFullName[sourceName][key]=sourceKeyValues[key]);
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
