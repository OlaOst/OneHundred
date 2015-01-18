module systems.networkhandler;

import std.algorithm;
import std.conv;
import std.parallelism;
import std.range;
import std.stdio;

import vibe.d;

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
    dur!"msecs"(1000).sleep;
    
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
    writeln("reading message ", message);
    foreach (index, thebyte; dst)
      dst[index] = message[index];
  }
}

class NetworkHandler : System!(NetworkInfo)
{
  NetworkWriter writer;
  
  bool hasLoopbackConnection = false;
  
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
      
      // setup loopback connection
      if (!hasLoopbackConnection)
      {
        hasLoopbackConnection = true;
        auto loopbackConnection = connectTCP(connection.remoteAddress.toAddressString, 5577);
        loopbackConnection.write("holla");
        loopbackConnection.flush;
      }
      
      connection.write(writer);
    }, TCPListenOptions.distribute);
    
    //auto connection = connectTCP("127.0.0.1", 5577);
    //connection.write("holla");
    //connection.flush();
  }
    
  override bool canAddEntity(Entity entity)
  {
    return ("networked" in entity.values) !is null;
  }
  
  override NetworkInfo makeComponent(Entity entity)
  {
    NetworkInfo component = new NetworkInfo();

    component.valuesToWrite = entity.values;
    
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
      auto remoteEntityId = keyParts[0].to!string.retro.to!string;
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

    string[string] data;
    foreach (key, value; outgoingData)
    {
      if (key in formerOutgoingData && formerOutgoingData[key] != value)
        data[key] = value;
    }
    
    data["timestamp"] = Clock.currTime.toISOExtString();
    
    writer.message = data.to!string ~ "\r\n";
    
    formerOutgoingData = outgoingData;
  }
  
  string[string] formerOutgoingData;
  
  override void updateEntities()
  {
    foreach (index, component; components)
    {
      foreach (fullKey, value; component.valuesToRead)
      {
        auto keyParts = fullKey.retro.findSplit(".");
        auto remoteEntityId = keyParts[0].to!string.retro.to!string;
        auto key = keyParts[1].to!string.retro.to!string;
      
        entityForIndex[index].values[key] = value;
      }
    }
  }
  
  NetworkInfo[string] componentIdMapping;
}
