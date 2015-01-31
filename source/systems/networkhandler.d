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
  long localEntityId;
  long remoteEntityId;
  string[string] valuesToWrite; // to network
  string[string] lastSentValues;
  
  bool remoteComponent = false;
  bool sendChangedValues = false;
}

// TODO: NetworkHandler could be generalized into a StreamHandler that populates entities with data from streams, and writes entity data to streams
// TODO: use separate connections for commands/requests and data?
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
    
    //writeln("making network component from entity ", entity.id, " with values ", entity.values);
    
    component.localEntityId = entity.id;
    
    if ("remoteEntityId" in entity.values)
    {
      //writeln("networkhandler makeComponent with remoteid ", entity.values["remoteEntityId"]);
      entityForRemoteId[entity.values["remoteEntityId"].to!long] = entity;
      component.remoteComponent = true;
    }
    else
    {
      component.valuesToWrite = entity.values;
      
      if (requestedChangedValues)
        component.sendChangedValues = true;
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
        
        foreach (component; components.filter!(component => component.sendChangedValues))
        {
          foreach (key; component.valuesToWrite.byKey.filter!(key => component.lastSentValues.get(key, null) != component.valuesToWrite[key]))
          {
            auto sendKey = component.localEntityId.to!string ~ "." ~ key;
            outgoingData[sendKey] = component.valuesToWrite[key];
            component.lastSentValues[key] = component.valuesToWrite[key];
          }
        }
        
        string message = "";
        foreach (key, value; outgoingData)
          message ~= key ~ " = " ~ value ~ "\r\n";
        
        //if (message.length > 0)
          //writeln("setting outgoing message to \n---\n", message, "\n---");
        
        connection.sendMessage(message);
      }
    }
  }
  
  override void updateEntities()
  {
  }
  
  void startSendingData(ushort targetPort)
  {
    if (connection.sendingData)
      return;
    
    writeln("networkhandler startsendingdata on port ", targetPort);
    timer = new AccumulatorTimer(double.max, 1.0/30.0);
    connection.startSendingData(targetPort);
    
    connection.sendMessage("connection.port = " ~ connection.connection.localAddress.port.to!string ~ "\r\n");
  }
  
  void parseMessage(string message)
  {
    //writeln("parsing message \n---\n", message, "\n---");
    
    string[string][long] valuesForNewEntities;
  
    foreach (keyValue; message.splitLines.map!(line => line.strip)
                                         .filter!(line => !line.empty)
                                         .filter!(line => !line.startsWith("#"))
                                         .map!(line => line.split("=")))
    {
      auto fullKey = keyValue[0].strip.to!string;
      //auto keyParts = fullKey.retro.findSplit(".");
      //auto messageType = keyParts[2].to!string.retro.to!string;
      //auto key = keyParts[0].to!string.retro.to!string;
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
        if (key == "port" && !connection.sendingData)
        {
          auto sourcePort = value.to!ushort;
          writeln("connecting back to connector at port ", sourcePort);
          startSendingData(sourcePort);
          connection.sendMessage("connection.accepted = true");
        }
        
        if (key == "accepted" && connection.sendingData)
        {
          writeln("got connection.accepted message");
          connection.sendMessage("request.changedValues = true");
          requestedChangedValues = true;
        }
      }
      else if (messageType == "request" && connection.sendingData)
      {
        if (key == "changedValues")
        {
          foreach (component; components.filter!(component => !component.remoteComponent))
          {
            //component.sendAllValues = false;
            component.sendChangedValues = true;
          }
          
          if (!requestedChangedValues)
          {
            connection.sendMessage("request.changedValues = true");
            requestedChangedValues = true;
          }
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
  bool requestedChangedValues = false;
}
