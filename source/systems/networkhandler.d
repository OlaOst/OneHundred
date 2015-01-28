module systems.networkhandler;

import core.thread;
import std.algorithm;
import std.conv;
import std.parallelism;
import std.range;
import std.stdio;

import vibe.d;

import accumulatortimer;
import app;
import entity;
import system;


class NetworkInfo
{
  long remoteEntityId;
  string[string] valuesToWrite; // to network
  string[string] valuesToRead; // from network
  
  //string[string] remoteValueUpdates;
}

class NetworkHandler : System!(NetworkInfo)
{
  AccumulatorTimer timer;
  ubyte[] data;
  /*__gshared*/ UDPConnection outgoingConnection;
  UDPConnection incomingConnection;
  bool hasOutgoingConnection = false;
  
  this()
  {
    //timer = new AccumulatorTimer(double.max, 1.0/20.0);
    
    //setLogLevel(LogLevel.trace);
    
    auto listenTask = task({ runTask({udpListen();}); runEventLoop(); });
    listenTask.executeInNewThread();
  }
  
  void udpListen()
  {
    incomingConnection = listenUDP(port);
    
    while (true)
    {
      auto pack = incomingConnection.recv();
      // TODO: for now assume one pack contains a complete message.
      parseMessage(cast(string)pack);
    }
  }
  
  void udpSender(ushort targetPort)
  {
    outgoingConnection = listenUDP(0);
    outgoingConnection.connect("127.0.0.1", targetPort);
    
    /*while (true)
    {
      // TODO: use AccumulatorTimer instead to slow down outgoing messages
      sleep(dur!"msecs"(100));
      if (outgoingMessage != null && outgoingMessage.length > 0)
        outgoingConnection.send(cast(ubyte[])outgoingMessage);
    }*/
  }
  
  void attemptConnection(ushort targetPort)
  {
    if (!hasOutgoingConnection)
    {
      auto senderTask = task({ runTask({udpSender(targetPort);}); runEventLoop(); });
      senderTask.executeInNewThread();
      
      timer = new AccumulatorTimer(double.max, 1.0/20.0);
      
      hasOutgoingConnection = true;
    }
    else
    {
      writeln("attemptConnection when already connected");
    }
  }
    
  override bool canAddEntity(Entity entity)
  {
    return ("networked" in entity.values) !is null || 
           ("remoteEntityId" in entity.values) !is null;
  }
  
  override NetworkInfo makeComponent(Entity entity)
  {
    NetworkInfo component = new NetworkInfo();

    component.valuesToWrite = entity.values;
    
    if ("remoteEntityId" in entity.values)
    {
      writeln("networkhandler makeComponent with remoteid ", entity.values["remoteEntityId"]);
      entityForRemoteId[entity.values["remoteEntityId"].to!long] = entity;
    }
    
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
    //writeln("parsing message ", message);
    
    string[string][long] valuesForNewEntities;
  
    foreach (keyValue; message.splitLines.map!(line => line.strip)
                                         .filter!(line => !line.empty)
                                         .filter!(line => !line.startsWith("#"))
                                         .map!(line => line.split("=")))
    {
      auto fullKey = keyValue[0].strip.to!string;
      auto keyParts = fullKey.retro.findSplit(".");
      auto remoteEntityId = keyParts[2].to!string.retro.to!string.to!long;
      auto key = keyParts[0].to!string.retro.to!string;
      
      auto value = keyValue[1].strip.to!string; //.parseValue(key).to!string;
      
      if (remoteEntityId !in entityForRemoteId)
      {
        valuesForNewEntities[remoteEntityId][key] = value;
      }
      else
      {
        auto entity = entityForRemoteId[remoteEntityId];
        
        //writeln("found remoteEntityId, setting remoteValueUpdates on component");
        
        //component.remoteValueUpdates[key] = value;
        // TODO: filter away keys that should not be updated over network
        // TODO: updating entity values directly like this should be done in updateEntities
        entity.values[key] = value;
      }
    }
    
    //writeln("valuesfornewentities: ", valuesForNewEntities);
    foreach (remoteEntityId, keyValues; valuesForNewEntities)
    {
      //writeln("adding remote entity with remotekey ", remoteEntityId, ", values ", keyValues);
      
      auto entity = new Entity(keyValues);
      entity.values["remoteEntityId"] = remoteEntityId.to!string;
      
      entitiesToBeAdded ~= entity;
    }
  }
  
  override void updateValues()
  {
    if (hasOutgoingConnection && outgoingConnection !is null)
    {
      timer.incrementAccumulator();
      
      //import std.math;
      //writeln("updatevalues running ", (timer.accumulator / timer.timeStep).floor, " updates");
      while (timer.accumulator >= timer.timeStep)
      {
        timer.accumulator -= timer.timeStep;
      
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
          //if (key !in formerOutgoingData || (key in formerOutgoingData && formerOutgoingData[key] != value))
          {
            data[key] = value;
            formerOutgoingData[key] = value;
          }
        }
        //formerOutgoingData = data.dup;
        
        string message = "";
        foreach (key, value; data)
        {
          message ~= key ~ " = " ~ value ~ "\r\n";
        }
        outgoingMessage = message;
        //message ~= "timestamp" ~ " = " ~ Clock.currTime.to!string;
        //writeln("setting outgoingmessage to ", outgoingMessage);
        
        outgoingConnection.send(cast(ubyte[])outgoingMessage);
      }
    }
  }
  
  override void updateEntities()
  {
    /*foreach (index, component; components)
    {
      foreach (key, value; component.remoteValueUpdates)
        entityForIndex[index].values[key] = value;
      
      component.remoteValueUpdates = null;
    }*/
  }
  
  string outgoingMessage;
  string[string] formerOutgoingData;
  //NetworkInfo[long] componentForRemoteId;
  Entity[long] entityForRemoteId;
  Entity[] entitiesToBeAdded;
}
