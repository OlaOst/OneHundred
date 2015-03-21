module systems.networkhandler;

import std.algorithm;
import std.conv;
import std.stdio;

import accumulatortimer;
import components.networkinfo;
import entity;
import networkconnection;
import networkmessageparser;
import system;


// TODO: NetworkHandler could be generalized into a StreamHandler
// TODO: use separate connections for commands/requests and data?
class NetworkHandler : System!(NetworkInfo)
{
  this(ushort listenPort)
  {
    connection = new NetworkConnection(listenPort, &parseMessage, this);
  }
  
  /*void close()
  {
    connection.close();
  }*/
  
  override bool canAddEntity(Entity entity)
  {
    return entity.has("networked") || entity.has("remoteEntityId");
  }
  
  override NetworkInfo makeComponent(Entity entity)
  {
    NetworkInfo component = new NetworkInfo();
    component.localEntityId = entity.id;
    
    if (entity.has("remoteEntityId"))
    {
      entityForRemoteId[entity.get!long("remoteEntityId")] = entity;
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
      foreach (key; component.valuesToWrite.byKey)
        component.valuesToWrite[key] = entityForIndex[index][key];
  }
  
  override void updateValues()
  {
    if (connection.sendingData && requestedChangedValues)
    {
      timer.incrementAccumulator();
      while (timer.accumulator >= timer.timeStep)
      {
        timer.accumulator -= timer.timeStep;
      
        string message = "";
        foreach (component; components)
        {
          foreach (key; component.valuesToWrite.byKey.
                        filter!(key => component.lastSentValues.get(key, null) != 
                                       component.valuesToWrite[key]))
          {
            auto sendKey = component.localEntityId.to!string ~ "." ~ key;
            message ~= sendKey ~ " = " ~ component.valuesToWrite[key] ~ "\r\n";
            component.lastSentValues[key] = component.valuesToWrite[key];
          }
        }
        connection.sendMessage(message);
      }
    }
  }
  
  override void updateEntities() {}
  
  void startSendingData(ushort targetPort)
  {
    if (connection.sendingData)
      return;
    
    timer = new AccumulatorTimer(double.max, 1.0/30.0);
    connection.startSendingData(targetPort);
    //connection.sendMessage("connection.port = " ~ 
                           //connection.connection.localAddress.port.to!string ~ "\r\n");
  }

  AccumulatorTimer timer;
  NetworkConnection connection;  
  string[string] formerOutgoingData;
  Entity[long] entityForRemoteId;
  Entity[] entitiesToBeAdded;
  bool requestedChangedValues = false;
}
