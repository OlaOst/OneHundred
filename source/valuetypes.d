module valuetypes;

import gl3n.linalg;


auto immutable vec2Types = ["position", "velocity", "force"];
auto immutable vec4Types = ["color"];
auto immutable doubleTypes = ["size", "angle", "rotation", "torque", "mass", "lifeTime"];
auto immutable fileTypes = ["sprite", "sound"];

static ValueType DefaultValue(ValueType)()
{
  static if (is(ValueType == double))
    return 0.0;
  else static if (is(ValueType == vec2))
    return vec2(0.0, 0.0);
  else static if (is(ValueType == vec4))
    return vec4(0.0, 0.0, 0.0, 0.0);
  else
    return ValueType.init;
}
