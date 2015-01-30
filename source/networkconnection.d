module networkconnection;

import std.parallelism;

import vibe.d;


// what kind of messages can the networkhandler send?
// 'i want to connect' message
// 'i accept your connection'
// ('i refuse your connection' - implicit if just ignoring, no reply gotten?)
// 'send me all your stuff'
// 'send me diffs'

// sequence
// 1. Foo sends connect message to Bar
// 2. Bar receives connect message, sends back accept connect message
// 3. Foo receives accept message, sends 'request full update' message to Bar
// 4. Bar receives 'request full update' message, sends all values of networked entities to Foo
// 4b. Bar sends 'requests full update' message to Foo
// 5. Foo receives full update message, creates remote-controlled entities ready to receive updates from Bar
// 6. Foo sends 'request incremental updates' to Bar
// 7. Bar receives 'request incremental updates', starts streaming messages of diffs of values of networked entities to Foo

// which sequence elements can be done simultaneously?
// no requesting data until accept connect message received
// TODO: error handling, checksums, what values should be sent, how often, how many at once, how many per second

class NetworkConnection
{
  this(ushort listenPort, void delegate(string) parseMessage)
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
          parseMessage(cast(string)pack);
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
