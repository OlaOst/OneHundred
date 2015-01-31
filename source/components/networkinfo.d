module components.networkinfo;


class NetworkInfo
{
  long localEntityId;
  long remoteEntityId;
  string[string] valuesToWrite; // to network
  string[string] lastSentValues;
  
  bool remoteComponent = false;
}
