module audio.wavheader;

import std.exception;

import derelict.openal.al;


void parseWavHeader(const ubyte[] headerData, ref ushort channels, ref ALsizei frequency, ref uint size)
{
  enforce(headerData.length >= 44, "Problem parsing wav file header");
  enforce(headerData[0..4] == "RIFF", "Problem parsing wav file header");
  // skip size value (4 bytes)
  enforce(headerData[8..12] == "WAVE", "Problem parsing wav file header");
  // skip "fmt", format length, format tag (10 bytes)
  channels = (cast(ushort[])headerData[22..24])[0];
  frequency = (cast(ALsizei[])headerData[24..28])[0];
  // skip average bytes per second, block align, bytes by capture (6 bytes)
  ushort bits = (cast(ushort[])headerData[34..36])[0];
  // skip 'data' (4 bytes)
  size = (cast(uint[])headerData[40..44])[0];
}
