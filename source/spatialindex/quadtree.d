module spatialindex.quadtree;

import std.algorithm;
import std.range;

import gl3n.aabb;

import spatialindex.spatialindex;


class QuadTree(Element) : SpatialIndex!Element
{
  AABB coveringArea;
  Node!Element rootNode;
  
  this()
  {
    coveringArea = AABB(vec3(-65536.0, -65536.0, -65536.0), vec3(65536.0, 65536.0, 65536.0));
    rootNode = new Node!Element(coveringArea);
  }
  
  void insert(Element element)
  {
    rootNode.insert(element);
  }
  
  Element[] find(AABB searchBox)
  {
    return rootNode.find(searchBox);
  }
}

class Node(Element)
{
  static enum se = 0;
  static enum sw = 1;
  static enum nw = 2;
  static enum ne = 3;
  
  static enum double minimumSize = 2.0;
  
  Node!Element[] corner;
  Element[] elements;
  
  AABB area;
  
  this(AABB area)
  {
    this.area = area;
    assert(area.extent.x == area.extent.y);
  }
  
  bool isLeafNode()
  {
    return area.extent.x <= minimumSize;
    //return corner.length == 0;
  }
  
  void insert(Element element)
  {
    //import std.stdio;
    //writeln("inserting element with aabb ", element.aabb, " in node ", area);
    
    if (element.aabb.intersects(area))
    {
      if (isLeafNode)
      {
        elements ~= element;
      }
      else
      {
        if (corner.length == 0)
        {
          corner.length = 4;
        
          corner[se] = new Node!Element(AABB(area.min, area.min + area.half_extent));
          corner[sw] = new Node!Element(AABB(vec3(area.min.x + area.half_extent.x, area.min.y, area.min.z), 
                                             vec3(area.max.x, area.max.y - area.half_extent.y, area.max.z)));
          corner[nw] = new Node!Element(AABB(area.max - area.half_extent, area.max));
          corner[ne] = new Node!Element(AABB(vec3(area.min.x, area.min.y + area.half_extent.y, area.min.z),
                                             vec3(area.max.x - area.half_extent.x, area.max.y, area.max.z)));
        }
        
        corner.each!(c => c.insert(element));
      }
    }
  }
  
  Element[] find(AABB searchBox)
  {
    //import std.stdio;
    //writeln("searchbox ", searchBox, " finding stuff in node ", area);
    if (searchBox.intersects(area))
    {
      if (isLeafNode)
      {
        return elements;
      }
      else
      {
        return corner.map!(c => c.find(searchBox)).join.array;
      }
    }
    return null;
  }
}
