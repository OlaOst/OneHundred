module systems.networkhandler;

import std.algorithm;
import std.conv;
import std.parallelism;
import std.range;
import std.stdio;

import vibe.d;

import app;
import entity;
import system;


class NetworkInfo
{
  long remoteEntityId;
  string[string] valuesToWrite; // to network
  string[string] valuesToRead; // from network
  
  string[string] remoteValueUpdates;
}

class NetworkHandler : System!(NetworkInfo)
{
  ubyte[] data;
  ConnectionStream outgoingConnection;
  MemoryStream outgoingStream;
  MemoryOutputStream incomingStream;
  
  bool isConnected = false;
  
  this()
  {
    outgoingStream = new MemoryStream(data);
    incomingStream = new MemoryOutputStream();
    
    auto vibeTask = task(&runEventLoop);
    vibeTask.executeInNewThread();
    
    listenTCP(port, (connection) 
    { 
      writeln("got connection from ", connection.remoteAddress, " to ", connection.localAddress);
      
      pipeRealtime(incomingStream, connection);
    }, TCPListenOptions.distribute);
  }

  
  void attemptConnection(ushort targetPort)
  {
    if (!isConnected)
    {
      writeln("attempting connection on port ", targetPort);
    
      isConnected = true;
      outgoingConnection = connectTCP("127.0.0.1", targetPort);
  
      //outgoingConnection.write(outgoingStream);
    }
    else
    {
      writeln("attemptConnection when already connected");
    }
  }
    
  override bool canAddEntity(Entity entity)
  {
    return ("networked" in entity.values) !is null;
  }
  
  override NetworkInfo makeComponent(Entity entity)
  {
    NetworkInfo component = new NetworkInfo();

    component.valuesToWrite = entity.values;
    
    //componentForRemoteId[entity.id] = component;
    
    if ("remoteEntityId" in entity.values)
      componentForRemoteId[entity.values["remoteEntityId"].to!long] = component;
    
    return component;
  }
  
  override void updateFromEntities()
  {
    foreach (index, component; components)
    {
      foreach (key; component.valuesToWrite.byKey)
      {
        component.valuesToWrite[key] = entityForIndex[index].values[key];
      }
    }
  }
  
  void parseMessage(string message)
  {
    writeln("parsing message ", message);
  
    foreach (keyValue; message.splitLines.map!(line => line.strip)
                                         .filter!(line => !line.empty)
                                         .filter!(line => !line.startsWith("#"))
                                         .map!(line => line.split("=")))
    {
      auto fullKey = keyValue[0].strip.to!string;
      //auto value = keyValue[1].strip.to!string;
      //values[key] = value.parseValue(key);
      
      auto keyParts = fullKey.retro.findSplit(".");
      
      writeln("parsing keyParts, remote id ", keyParts[2].to!string.retro.to!string);
      writeln("parsing keyParts, key ", keyParts[0].to!string.retro.to!string);
      
      auto remoteEntityId = keyParts[2].to!string.retro.to!string.to!long;
      auto key = keyParts[0].to!string.retro.to!string;
      
      writeln("parsed remoteid ", remoteEntityId, " and key ", key);
      
      auto value = keyValue[1].strip.to!string; //.parseValue(key).to!string;
      
      writeln("attempting to find ", remoteEntityId);
      
      if (remoteEntityId !in componentForRemoteId)
      {
        // create new entity
        writeln("did not find remoteEntityId ", remoteEntityId, " in componentForRemoteId ", componentForRemoteId, ", supposed to create new entity now");
      }
      else
      {
        auto component = componentForRemoteId[remoteEntityId];
        
        writeln("found remoteEntityId, setting remoteValueUpdates on component");
        
        component.remoteValueUpdates[key] = value;
      }
    }
  }
  
  override void updateValues()
  {
    // TODO: for now we just assume we get a fully formed perfect block of data
    auto incomingMessage = cast(string)incomingStream.data;
    
    if (incomingMessage.length > 0)
    {
      //writeln("updateValues, incomingmessage ", incomingMessage);
      parseMessage(incomingMessage);
      incomingStream.reset;
    }
    
    if (isConnected)
    {
      string[string] outgoingData;
      
      foreach (index, component; components)
      {
        foreach (key, value; component.valuesToWrite)
        {
          outgoingData[entityForIndex[index].id.to!string ~ "." ~ key] = value;
        }
      }
      
      string[string] data;
      foreach (key, value; outgoingData)
      {
        if (key !in formerOutgoingData || formerOutgoingData[key] != value)
          data[key] = value;
      }
      
      string message = "";
      foreach (key, value; data)
      {
        message ~= key ~ " = " ~ value ~ "\r\n";
      }
      //writeln("writing message to outgoingConnection: ", message);
      outgoingConnection.write(cast(ubyte[])message);      
    }
  }
  
  string[string] formerOutgoingData;
  
  override void updateEntities()
  {
    foreach (index, component; components)
    {
      //foreach (fullKey, value; component.valuesToRead)
      foreach (key, value; component.remoteValueUpdates)
      {
        //auto keyParts = fullKey.retro.findSplit(".");
        //auto remoteEntityId = keyParts[0].to!string.retro.to!string;
        //auto key = keyParts[1].to!string.retro.to!string;
      
        writeln("updateEntities, entity ", entityForIndex[index].id, ", updating ", key, " to ", value);
      
        entityForIndex[index].values[key] = value;
      }
      
      component.remoteValueUpdates = null;
    }
  }
  
  NetworkInfo[long] componentForRemoteId;
}
