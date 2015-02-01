module networkconnection;

import std.parallelism;

import vibe.d;

import systems.networkhandler;


// TODO: error handling, checksums, rate and volume limiting
class NetworkConnection
{
  this(ushort listenPort, 
       void function(string, NetworkHandler) parseMessage, 
       NetworkHandler networkHandler)
  {
    //setLogLevel(LogLevel.trace);
    
    auto listenTask = task(
    { 
      runTask(
      {
        connection = listenUDP(listenPort);
    
        while (true)
        {
          auto pack = connection.recv();
          // TODO: for now assume one pack contains a complete message.
          parseMessage(cast(string)pack, networkHandler);
        }
      }); 
      
      runEventLoop(); 
    });
    listenTask.executeInNewThread();
  }
  
  void startSendingData(ushort targetPort)
  {
    if (!sendingData)
    {
      connection.connect("127.0.0.1", targetPort);
      
      //timer = new AccumulatorTimer(double.max, 1.0/20.0);
      
      sendingData = true;
    }
  }
  
  void sendMessage(string message)
  {
    connection.send(cast(ubyte[])message);
  }
  
  ubyte[] data;
  UDPConnection connection;
  bool sendingData = false;
}
