module networkmessageparser;

import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.string;

import entity;
import systems.networkhandler;


void parseMessage(string message, NetworkHandler networkHandler)
{
  string[string][long] valuesForNewEntities;

  foreach (keyValue; message.splitLines.map!(line => line.strip)
                                       .filter!(line => !line.empty)
                                       .filter!(line => !line.startsWith("#"))
                                       .map!(line => line.split("=")))
  {
    auto fullKey = keyValue[0].strip.to!string;
    auto keyParts = fullKey.findSplit(".");
    auto messageType = keyParts[0];
    auto key = keyParts[2];
    auto value = keyValue[1].strip.to!string; //.parseValue(key).to!string;
    
    scope(failure) writeln("parseMessage failure, keyvalue ", keyValue, 
                                              "\nfullKey ", fullKey,
                                              "\nkeyParts ", keyParts,
                                              "\nmessageType ", messageType,
                                              "\nkey ", key,
                                              "\nvalue ", value);
    
    if (messageType == "connection")
    {
      // connect back to connector if not already connected
      if (key == "port" && !networkHandler.connection.sendingData)
      {
        auto sourcePort = value.to!ushort;
        writeln("connecting back to connector at port ", sourcePort);
        networkHandler.startSendingData(sourcePort);
        networkHandler.connection.sendMessage("connection.accepted = true");
      }
      
      if (key == "accepted" && networkHandler.connection.sendingData)
      {
        writeln("got connection.accepted message");
        networkHandler.connection.sendMessage("request.changedValues = true");
        networkHandler.requestedChangedValues = true;
      }
    }
    else if (messageType == "request" && networkHandler.connection.sendingData)
    {
      if (key == "changedValues")
      {
        if (!networkHandler.requestedChangedValues)
        {
          networkHandler.connection.sendMessage("request.changedValues = true");
          networkHandler.requestedChangedValues = true;
        }
      }
    }
    else
    {
      auto remoteEntityId = messageType.to!long;
      
      if (remoteEntityId !in networkHandler.entityForRemoteId)
      {
        valuesForNewEntities[remoteEntityId][key] = value;
      }
      else
      {
        auto entity = networkHandler.entityForRemoteId[remoteEntityId];
        
        //component.remoteValueUpdates[key] = value;
        // TODO: filter away keys that should not be updated over network
        // TODO: updating entity values directly like this should be done in updateEntities
        entity.values[key] = value;
      }
    }
  }
  
  foreach (remoteEntityId, keyValues; valuesForNewEntities)
  {
    auto entity = new Entity(keyValues);
    entity.values["remoteEntityId"] = remoteEntityId.to!string;
    networkHandler.entitiesToBeAdded ~= entity;
  }
}
