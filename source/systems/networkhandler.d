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

class NetworkWriter : InputStream
{
  string message = "ikke no nytt\n";
  
  bool empty() @property
  {
    dur!"msecs"(100).sleep;
    
    return message.length <= 0;
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
  
  bool isConnected = false;
  
  this()
  {    
    auto vibeTask = task(&runEventLoop);
    vibeTask.executeInNewThread();
    
    writer = new NetworkWriter();
    
    ubyte[1024] buffer;
    
    listenTCP(port, (connection) 
    { 
      writeln("got connection from ", connection.remoteAddress, " to ", connection.localAddress);
      
      connection.write("hello\r\n");
      connection.flush;
      
      // establish twoway connection
      attemptConnection(cast(ushort)(connection.localAddress.port - 1));
      
      while(!connection.empty)
      {
        scope(exit) writeln("connection empty");
        
        ubyte[] buffer;
        buffer.length = cast(size_t)connection.leastSize;
        
        connection.read(buffer);
        
        writeln("recieved data: ", cast(string)buffer, ", size ", buffer.length);
        parseMessage(cast(string)buffer);
      }
      
    }, TCPListenOptions.distribute);
  }

  TCPConnection connection;
  
  void attemptConnection(ushort targetPort)
  {
    if (!isConnected)
    {
      writeln("attempting connection on port ", targetPort);
    
      isConnected = true;
      connection = connectTCP("127.0.0.1", targetPort);
      //connection.write("connected!");
      //connection.flush;
      //connection.write(writer);
      
      // TODO: the connection should stream network data
    }
    else
    {
      writeln("attempConnection when already connected");
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
    // read stream of key/values from network
    // key should identify component/entity and the value to update, i.e. playership.position = [0.5, 0.4]
    string[string] incomingData;
    
    /*foreach (fullKey, value; incomingData)
    {
      // find matching component
      auto keyParts = fullKey.retro.findSplit(".");
      auto remoteEntityId = keyParts[0].to!string.retro.to!string;
      auto key = keyParts[1].to!string.retro.to!string;
      
      auto remoteId = key.to!long;
      
      if (key !in componentForRemoteId)
      //auto component = componentForRemoteId[key.to!long];
      
      component.valuesToRead[key] = value;
    }*/
    
    string[string] outgoingData;
    
    foreach (index, component; components)
    {
      foreach (key, value; component.valuesToWrite)
      {
        outgoingData[entityForIndex[index].id.to!string ~ "." ~ key] = value;
      }
    }
    
    writeln("outgoing data ", outgoingData.length);

    string[string] data;
    foreach (key, value; outgoingData)
    {
      if (key in formerOutgoingData && formerOutgoingData[key] != value)
        data[key] = value;
    }
    
    //data["timestamp"] = Clock.currTime.toISOExtString();

    writer.message = "";
    foreach (key, value; data)
      writer.message ~= key ~ " = " ~ value ~ "\r\n";
    
    if (writer.message.length > 0)
      writeln("setting networkwriter message to ", writer.message);
    
    if (connection !is null && connection.connected)
      connection.write(writer);
    
    //writer.message = data.to!string ~ "\r\n";
    
    formerOutgoingData = outgoingData;
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
      
        writeln("NetworkHandler, entity ", entityForIndex[index].id, ", updating ", key, " to ", value);
      
        entityForIndex[index].values[key] = value;
      }
      
      component.remoteValueUpdates = null;
    }
  }
  
  NetworkInfo[long] componentForRemoteId;
}
