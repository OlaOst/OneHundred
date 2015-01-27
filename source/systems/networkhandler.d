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
  
  string[string] remoteValueUpdates;
}

class NetworkHandler : System!(NetworkInfo)
{
  AccumulatorTimer timer;
  ubyte[] data;
  ConnectionStream outgoingConnection;
  MemoryStream outgoingStream;
  MemoryOutputStream incomingStream;
  
  bool hasOutgoingConnection = false;
  
  this()
  {
    timer = new AccumulatorTimer(double.max, 1.0/2.0);
    
    outgoingStream = new MemoryStream(data);
    incomingStream = new MemoryOutputStream();
    
    //auto vibeTask = task(&vibeLoop);
    //vibeLoop.executeInNewThread();
    auto vibeThread = new Thread({ vibeLoop(); });
    vibeThread.start();
    
    //setLogLevel(LogLevel.trace);
    
    /+listenTCP(port, (connection) 
    { 
      writeln("got connection from ", connection.remoteAddress, " to ", connection.localAddress);
      
      pipeRealtime(incomingStream, connection);//, 0, 20.msecs); //(timer.timeStep * 1_000_000).to!long.usecs);
      //incomingStream.write(connection);
      connection.tcpNoDelay = true;
    }, TCPListenOptions.distribute);+/
  }

  void vibeLoop()
  {
    runTask({udpListen();});
    //runTask({udpSender(cast(ushort)(port+1));});
    runEventLoop();
  }
  
  void udpListen()
  {
    //logTrace("setting up udpListener on port ", port.to!string);
    writeln("setting up udpListener on port ", port.to!string);
    auto udpListener = listenUDP(port);    
    writeln("set up udpListener");
    
    while (true)
    {
      //logTrace("updListen, receiving pack from ", udpListener.localAddress.to!string, ", bindaddress ", udpListener.bindAddress.to!string);
      try
      {
        auto pack = udpListener.recv();
        writeln("got udp packet: ", cast(string)pack);
        incomingStream.write(/*cast(string)*/pack);
      }
      catch (Exception e)
      {
        writeln("timeout on udp listen, retrying");
      }
    }
  }
  
  void udpSender(ushort targetPort)
  {
    writeln("setting up udpsender on port ", targetPort.to!string);
    auto udpSenderConn = listenUDP(0);
    udpSenderConn.connect("127.0.0.1", targetPort);
    writeln("set up udpsender");
    
    while (true)
    {
      sleep(dur!"msecs"(100));
      writeln("sending packet from ", udpSenderConn.localAddress, ", bindaddress ", udpSenderConn.bindAddress, " on port ", targetPort.to!string, ", content ", outgoingMessage);
      //udpSenderConn.send(cast(ubyte[])"hello"); //, &host);
      udpSenderConn.send(cast(ubyte[])outgoingMessage); //, &host);
    }
  }
  
  void attemptConnection(ushort targetPort)
  {
    if (!hasOutgoingConnection)
    {
      writeln("attempting connection on port ", targetPort);
      /+
      outgoingConnection = connectTCP("127.0.0.1", targetPort);
      (cast(TCPConnection)outgoingConnection).tcpNoDelay = true;
      
      hasOutgoingConnection = true;
      
      //runTask({
        if (outgoingMessage.length > 0)
        {
          writeln("writing message to outgoingConnection: ", outgoingMessage);
          outgoingConnection.write(cast(ubyte[])outgoingMessage);
          
          //outgoingConnection.write(cast(ubyte[])message);
          //writeln("leastsize before flush: ", outgoingConnection.leastSize);
          outgoingConnection.flush();
          //writeln("leastsize after flush: ", outgoingConnection.leastSize);
        }
      //});

      //outgoingConnection.write(outgoingStream);
      +/
      
      //runTask({udpSender();});
      auto senderTask = task({ runTask({udpSender(targetPort);}); runEventLoop(); });
      senderTask.executeInNewThread();
      
      hasOutgoingConnection = true;
    }
    else
    {
      writeln("attemptConnection when already connected");
    }
  }
    
  override bool canAddEntity(Entity entity)
  {
    return ("networked" in entity.values) !is null || ("remoteEntityId" in entity.values) !is null;
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
    writeln("parsing message with length ", message.length);
  
    string[string][long] valuesForNewEntities;
  
    foreach (keyValue; message.splitLines.map!(line => line.strip)
                                         .filter!(line => !line.empty)
                                         .filter!(line => !line.startsWith("#"))
                                         .map!(line => line.split("=")))
    {
      auto fullKey = keyValue[0].strip.to!string;
      //auto value = keyValue[1].strip.to!string;
      //values[key] = value.parseValue(key);
      
      auto keyParts = fullKey.retro.findSplit(".");
      
      //writeln("parsing keyParts, remote id ", keyParts[2].to!string.retro.to!string);
      //writeln("parsing keyParts, key ", keyParts[0].to!string.retro.to!string);
      
      auto remoteEntityId = keyParts[2].to!string.retro.to!string.to!long;
      auto key = keyParts[0].to!string.retro.to!string;
      
      //writeln("parsed remoteid ", remoteEntityId, " and key ", key);
      
      auto value = keyValue[1].strip.to!string; //.parseValue(key).to!string;
      
      //writeln("attempting to find ", remoteEntityId);
      
      if (remoteEntityId !in componentForRemoteId)
      {
        // create new entity
        writeln("did not find remoteEntityId ", remoteEntityId, " in componentForRemoteId ", componentForRemoteId, ", supposed to create new entity now");
        //auto entity = new Entity();
        //entitiesToBeAdded ~= entity;
        valuesForNewEntities[remoteEntityId][key] = value;
      }
      else
      {
        auto component = componentForRemoteId[remoteEntityId];
        
        //writeln("found remoteEntityId, setting remoteValueUpdates on component");
        
        component.remoteValueUpdates[key] = value;
      }
    }
    
    foreach (remoteEntityId, keyValues; valuesForNewEntities)
    {
      writeln("adding remote entity with remotekey ", remoteEntityId, ", values ", keyValues);
      
      auto entity = new Entity(keyValues);
      entity.values["remoteEntityId"] = remoteEntityId.to!string;
      
      entitiesToBeAdded ~= entity;
    }
  }
  
  override void updateValues()
  {
    yield();
    
    // TODO: for now we just assume we get a fully formed perfect block of data
    auto incomingMessage = cast(string)incomingStream.data;
    
    // TODO: what if incomingMessage contains multiple updates for a value? need to sort/order by timestamp?
    if (incomingMessage.length > 0)
    {
      //writeln("updateValues, incomingmessage ", incomingMessage);
      parseMessage(incomingMessage);
      incomingStream.reset;
    }
    
    if (hasOutgoingConnection)
    {
      timer.incrementAccumulator();
      
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
        
        //runTask({
          //writeln("writing message to outgoingConnection: ", message);
          //outgoingBuffer[] = 0;
          //outgoingBuffer[0..message.length] = cast(ubyte[])message;
          //outgoingConnection.write(outgoingBuffer);
          //outgoingConnection.write(cast(ubyte[])message);
          
          // calling leastSize here locks up while waiting for new data
          //writeln("leastsize before flush: ", outgoingConnection.leastSize);
          
          //auto duhTask = task(&outgoingConnection.leastSize);
          //duhTask.executeInNewThread();
          
          //outgoingConnection.flush();
          //writeln("leastsize after flush: ", outgoingConnection.leastSize);
        //});
      }
    }
  }
  
  ubyte[4096] outgoingBuffer;
  
  string outgoingMessage;
  
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
      
        //writeln("updateEntities, entity ", entityForIndex[index].id, ", updating ", key, " to ", value);
      
        entityForIndex[index].values[key] = value;
      }
      
      component.remoteValueUpdates = null;
    }
  }
  
  NetworkInfo[long] componentForRemoteId;
  Entity[] entitiesToBeAdded;
}
