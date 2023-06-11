module bitops;

import std.conv;

import inmath.aabb;
import inmath.linalg;


bool contains(AABB container, AABB content) pure nothrow @nogc
{
   return (container.min.x < content.min.x && 
           container.max.x > content.max.x &&
           container.min.y < content.min.y &&
           container.max.y > content.max.y);
}

uint powerOf2(uint n) pure nothrow @nogc
{
  uint level = 0;
  
  while (n > 1)
  {
    n >>= 1;
    level++;
  }
  return level;
}

// hash x and y of a position into an uint
uint index(vec3 position) pure nothrow @nogc
{
  // TODO: make sure values are clamped not wrapped
  return interleave(cast(uint)position.x + 2^^15, cast(uint)position.y + 2^^15);
}

// will extract even bits
int deinterleave(int z) pure nothrow @nogc
in
{
  assert(z >= -2^^31 && z < 2^^31-1);
  //assert(z >= -2^^31 && z < 2^^31-1, 
         //"Tried to call deinterleave with z out of bounds: " ~ to!string(z));
}
do
{
  z = z & 0x55555555;
  
  z = (z | (z >> 1)) & 0x33333333;
  z = (z | (z >> 2)) & 0x0F0F0F0F;
  z = (z | (z >> 4)) & 0x00FF00FF;
  z = (z | (z >> 8)) & 0x0000FFFF;
  
  return z;
}

uint interleave(uint x, uint y) pure nothrow @nogc
in
{
  assert(x >= 0 && x < 2^^16);
  assert(y >= 0 && y < 2^^16);
  //assert(x >= 0 && x < 2^^16, "Tried to call interleave with x out of bounds: " ~ x.to!string);
  //assert(y >= 0 && y < 2^^16, "Tried to call interleave with y out of bounds: " ~ y.to!string);
}
do
{
  // from http://graphics.stanford.edu/~seander/bithack.html#InterleaveBMN
  static immutable uint[] B = [0x55555555, 0x33333333, 0x0F0F0F0F, 0x00FF00FF];
  static immutable uint[] S = [1, 2, 4, 8];

  // Interleave lower 16 bits of x and y, so the bits of x
  // are in the even positions and bits from y in the odd;
  
  uint z; // z gets the resulting 32-bit Morton Number.  
          // x and y must initially be less than 65536.

  x = (x | (x << S[3])) & B[3];
  x = (x | (x << S[2])) & B[2];
  x = (x | (x << S[1])) & B[1];
  x = (x | (x << S[0])) & B[0];

  y = (y | (y << S[3])) & B[3];
  y = (y | (y << S[2])) & B[2];
  y = (y | (y << S[1])) & B[1];
  y = (y | (y << S[0])) & B[0];

  z = x | (y << 1);
  
  return z;
}
