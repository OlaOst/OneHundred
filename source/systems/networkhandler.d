module systems.networkhandler;

import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.string;

import accumulatortimer;
import entity;
import networkconnection;
import system;


class NetworkInfo
{
  long remoteEntityId;
  string[string] valuesToWrite; // to network
  string[string] valuesToRead; // from network
  
  bool remoteComponent = false;
}

// TODO: NetworkHandler could be generalized into a StreamHandler that populates entities with data from streams, and writes entity data to streams
class NetworkHandler : System!(NetworkInfo)
{
  private AccumulatorTimer timer;
  private NetworkConnection connection;

  this(ushort listenPort)
  {
    connection = new NetworkConnection(listenPort, &parseMessage);
  }
  
  override bool canAddEntity(Entity entity)
  {
    return ("networked" in entity.values) !is null || 
           ("remoteEntityId" in entity.values) !is null;
  }
  
  override NetworkInfo makeComponent(Entity entity)
  {
    NetworkInfo component = new NetworkInfo();
    
    if ("remoteEntityId" in entity.values)
    {
      writeln("networkhandler makeComponent with remoteid ", entity.values["remoteEntityId"]);
      entityForRemoteId[entity.values["remoteEntityId"].to!long] = entity;
    }
    else
    {
      component.valuesToWrite = entity.values;
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
  
  override void updateValues()
  {
    if (connection.sendingData)
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
        
        //message ~= "connection.port" ~ " = " ~ connection.listenPort.to!string ~ "\r\n";
        
        foreach (key, value; data)
        {
          message ~= key ~ " = " ~ value ~ "\r\n";
        }
        //message ~= "timestamp" ~ " = " ~ Clock.currTime.to!string;
        //writeln("setting outgoing message to \n", message);
        
        connection.sendMessage(message);
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
  
  void startSendingData(ushort targetPort)
  {
    writeln("networkhandler startsendingdata on port ", targetPort);
    timer = new AccumulatorTimer(double.max, 1.0/20.0);
    connection.startSendingData(targetPort);
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
      auto messageType = keyParts[2].to!string.retro.to!string;
      auto key = keyParts[0].to!string.retro.to!string;
      auto value = keyValue[1].strip.to!string; //.parseValue(key).to!string;
      
      if (messageType == "connection")
      {
        // connect back to connector
        if (key == "port")
        {
          auto sourcePort = value.to!ushort;
          startSendingData(sourcePort);
        }
      }
      else
      {
        auto remoteEntityId = messageType.to!long;
        
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
  
  string[string] formerOutgoingData;
  Entity[long] entityForRemoteId;
  Entity[] entitiesToBeAdded;
}
