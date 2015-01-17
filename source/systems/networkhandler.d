module systems.networkhandler;

import std.algorithm;
import std.conv;
import std.parallelism;
import std.range;
//import std.socket;
import std.stdio;

import vibe.d;
//import vibe.appmain;
//import vibe.core.core;
//import vibe.core.net;

import entity;
import system;


class NetworkInfo
{
  long entityId;
  string[string] valuesToWrite; // to network
  string[string] valuesToRead; // from network
}

class NetworkWriter : InputStream
{
  string message = "ikke no nytt\n";
  
  bool empty() @ property
  {
    dur!"msecs"(500).sleep;
    
    return false;
  }
  
  ulong leastSize() @property
  {
    return message.length;
  }
  
  bool dataAvailableForRead() @property
  {
    return true;
  }
  
  const(ubyte)[] peek()
  {
    return message.to!(ubyte[]);
  }
  
  void read(ubyte[] dst)
  {
    foreach (index, thebyte; dst)
      dst[index] = message[index];
  }
}

class NetworkHandler : System!(NetworkInfo)
{
  NetworkWriter writer;
  
  this()
  {    
    auto vibeTask = task(&runEventLoop);
    vibeTask.executeInNewThread();
    
    writer = new NetworkWriter();
    
    ubyte[1024] buffer;
    
    listenTCP(5577, (connection) 
    { 
      writeln("got connection from ", connection.remoteAddress, " to ", connection.localAddress);
      
      connection.write("hello");
      
      connection.write(writer);
    }, TCPListenOptions.distribute);
    
    //auto connection = connectTCP("127.0.0.1", 5577);
    //connection.write("halla");
    //connection.flush();
  }
    
  override bool canAddEntity(Entity entity)
  {
    return ("networked" in entity.values) !is null;
  }
  
  override NetworkInfo makeComponent(Entity entity)
  {
    NetworkInfo component = new NetworkInfo();

    writeln("making component from entity with id ", entity.id);
    
    component.valuesToWrite = entity.values;
    //component.valuesToWrite["position"] = [0.0, 0.0].to!string;
    //component.valuesToWrite["angle"] = 0.0.to!string;
    
    componentIdMapping[entity.id.to!string] = component;
    
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
    // read stream of key/values from network
    // key should identify component/entity and the value to update, i.e. playership.position = [0.5, 0.4]
    string[string] incomingData;
    
    foreach (fullKey, value; incomingData)
    {
      // find matching component
      auto keyParts = fullKey.retro.findSplit(".");
      auto entityId = keyParts[0].to!string.retro.to!string;
      auto key = keyParts[1].to!string.retro.to!string;
      
      auto component = componentIdMapping[key];
      
      component.valuesToRead[key] = value;
    }
    
    string[string] outgoingData;
    
    foreach (index, component; components)
    {
      foreach (key, value; component.valuesToWrite)
      {
        outgoingData[entityForIndex[index].id.to!string ~ "." ~ key] = value;
      }
    }
    
    writer.message = outgoingData.to!string;
  }
  
  override void updateEntities()
  {
    foreach (index, component; components)
    {
      foreach (key, value; component.valuesToRead)
        entityForIndex[index].values[key] = value;
    }
  }
  
  NetworkInfo[string] componentIdMapping;
}
