module tests.entitycollection;

import entityfactory.entitycollection;


unittest
{
  string[] lines = ["parentname.parentkey = parentvalue",
                    "parentname.otherparentkey = otherparentvalue",
                    "parentname.childname.childkey = childvalue",
                    "parentname.childname.otherchildkey = otherchildvalue"];
                    
  auto entities = lines.createEntityCollection;
  
  assert("parentname" in entities);
  assert("parentname.childname" in entities);
  
  assert("parentkey" in entities["parentname"].values);
  assert(entities["parentname"].values["parentkey"] == "parentvalue");
  
  assert("otherparentkey" in entities["parentname"].values);
  assert(entities["parentname"].values["otherparentkey"] == "otherparentvalue");
  
  assert("childname.childkey" !in entities["parentname"].values);
  
  assert("childkey" in entities["parentname.childname"].values);
  assert(entities["parentname.childname"].values["childkey"] == "childvalue");
  
  assert("otherchildkey" in entities["parentname.childname"].values);
  assert(entities["parentname.childname"].values["otherchildkey"] == "otherchildvalue");
}

unittest
{
  string[] lines = ["parent.position = [0, 0, 0]",
                    "parent.child.childkey = childvalue",
                    "parent.child.relation.type = [\"RelativeValues\"]",
                    "parent.child.relation.target = parent",
                    "parent.child.relation.value.position = [0, 1, 0]"];
                    
  auto entities = lines.createEntityCollection;
  
  assert("parent" in entities);
  assert("parent.child" in entities);
  assert("parent.child.relation" !in entities);
  assert("parent.child.relation.type" !in entities);
}

unittest
{
  auto entities = "data/playership.txt".createEntityCollectionFromFile();

  assert("playership" in entities);
  assert("playership.hull" in entities);
  assert(entities["playership.hull"].get!double("mass") == 4.0);
}
