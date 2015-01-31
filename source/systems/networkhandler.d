module systems.networkhandler;

import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.string;

import accumulatortimer;
import components.networkinfo;
import entity;
import networkconnection;
import networkmessageparser;
import system;


// TODO: NetworkHandler could be generalized into a StreamHandler that populates entities with data from streams, and writes entity data to streams
// TODO: use separate connections for commands/requests and data?
class NetworkHandler : System!(NetworkInfo)
{
  this(ushort listenPort)
  {
    connection = new NetworkConnection(listenPort, &parseMessage, this);
  }
  
  override bool canAddEntity(Entity entity)
  {
    return ("networked" in entity.values) !is null || 
           ("remoteEntityId" in entity.values) !is null;
  }
  
  override NetworkInfo makeComponent(Entity entity)
  {
    NetworkInfo component = new NetworkInfo();
    component.localEntityId = entity.id;
    
    if ("remoteEntityId" in entity.values)
    {
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
    if (connection.sendingData && requestedChangedValues)
    {
      timer.incrementAccumulator();
      
      while (timer.accumulator >= timer.timeStep)
      {
        timer.accumulator -= timer.timeStep;
      
        string[string] outgoingData;
        
        foreach (component; components)
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

  AccumulatorTimer timer;
  NetworkConnection connection;  
  string[string] formerOutgoingData;
  Entity[long] entityForRemoteId;
  Entity[] entitiesToBeAdded;
  bool requestedChangedValues = false;
}
