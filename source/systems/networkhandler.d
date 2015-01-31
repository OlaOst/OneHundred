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
  string[string] lastSentValues;
  
  bool remoteComponent = false;
  bool sendAllValues = false;
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
    
    if ("remoteEntityId" in entity.values)
    {
      writeln("networkhandler makeComponent with remoteid ", entity.values["remoteEntityId"]);
      entityForRemoteId[entity.values["remoteEntityId"].to!long] = entity;
      component.remoteComponent = true;
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
        
        foreach (index, component; components.filter!(component => component.sendAllValues).array)
        {
          foreach (key, value; component.valuesToWrite)
          {
            auto sendKey = entityForIndex[index].id.to!string ~ "." ~ key;
            
            //writeln("building sendKey from key ", key, " and entityid ", entityForIndex[index].id, ": ", sendKey);
            
            outgoingData[sendKey] = value;
            component.lastSentValues[key] = value;
          }
          component.sendAllValues = false; // all values have been sent, no need to resend later on
        }
        
        foreach (index, component; components.filter!(component => component.sendChangedValues).array)
        {
          foreach (key; component.valuesToWrite.byKey.filter!(key => component.lastSentValues.get(key, null) != component.valuesToWrite[key]))
          {
            auto sendKey = entityForIndex[index].id.to!string ~ "." ~ key;
            outgoingData[sendKey] = component.valuesToWrite[key];
            component.lastSentValues[key] = component.valuesToWrite[key];
          }
        }
        
        //string message = "";
        
        //message ~= "connection.port" ~ " = " ~ connection.listenPort.to!string ~ "\r\n";
        
        //foreach (key, value; outgoingData)
        //{
          //message ~= key ~ " = " ~ value ~ "\r\n";
        //}
        //message ~= "timestamp" ~ " = " ~ Clock.currTime.to!string;
        
                
        //string message = reduce!((key, value) => key ~ " = " ~ value ~ "\r\n")("", outgoingData);
        string message = "";
        foreach (key, value; outgoingData)
          message ~= key ~ " = " ~ value ~ "\r\n";
        
        if (message.length > 0)
          writeln("setting outgoing message to \n---\n", message, "\n---");
        
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
    //assert(!connection.sendingData);
    if (connection.sendingData)
      return;
    
    writeln("networkhandler startsendingdata on port ", targetPort);
    timer = new AccumulatorTimer(double.max, 1.0/20.0);
    connection.startSendingData(targetPort);
    
    //message ~= "connection.port" ~ " = " ~ connection.listenPort.to!string ~ "\r\n";
    connection.sendMessage("connection.port = " ~ connection.connection.localAddress.port.to!string ~ "\r\n");
  }
  
  bool requestedAllValues = false;
  bool requestedChangedValues = false;
  void parseMessage(string message)
  {
    writeln("parsing message \n---\n", message, "\n---");
    
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
        // connect back to connector if not already connected
        if (key == "port" && !connection.sendingData)
        {
          auto sourcePort = value.to!ushort;
          writeln("connecting back to connector at port ", sourcePort);
          startSendingData(sourcePort);
          connection.sendMessage("connection.accepted = true");
        }
        
        if (key == "accepted" && connection.sendingData && !requestedAllValues)
        {
          writeln("got connection.accepted message");
          //connection.sendMessage("request.allValues = true");
          //requestedAllValues = true;
          connection.sendMessage("request.changedValues = true");
          requestedChangedValues = true;
        }
      }
      else if (messageType == "request" && connection.sendingData)
      {
        if (key == "allValues")
        {
          foreach (component; components.filter!(component => !component.remoteComponent))
          {
            component.sendAllValues = true;
            component.sendChangedValues = false;
          }
          
          if (!requestedAllValues)
          {
            connection.sendMessage("request.allValues = true");
            requestedAllValues = true;
          }
        }
        if (key == "changedValues")
        {
          foreach (component; components.filter!(component => !component.remoteComponent))
          {
            component.sendAllValues = false;
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
}
