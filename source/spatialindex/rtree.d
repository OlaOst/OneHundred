module spatialindex.rtree;

import std.algorithm;
import std.range;

import gl3n.aabb;
import gl3n.linalg;

import spatialindex.spatialindex;


alias RTree = Node;

class Node(Element) : SpatialIndex!Element
{
  static enum maxElements = 8;
  
  AABB aabb = AABB(vec3(0, 0, -1), vec3(0, 0, 1));
  int depth = 0;
  Node[] childNodes;
  Element[] elements;
  
  void insert(Element element)
  {
    if (elements.length == 0 && childNodes.length == 0)
      aabb = AABB(vec3(element.aabb.min.xy, -1.0), vec3(element.aabb.max.xy, 1.0));
    else
      aabb.expand(element.aabb);
    
    if (childNodes.length > 0)
    {
      auto bestNode = childNodes.minPos!((left, right) => left.aabb.expanded(element.aabb).area < 
                                                          right.aabb.expanded(element.aabb).area);
      bestNode[0].insert(element);
    }
    else
    {
      elements ~= element;
      if (elements.length >= maxElements)
        split();
    }
  }
  
  void split()
  {
    auto leftNode = new Node();
    auto rightNode = new Node();
    leftNode.depth = rightNode.depth = this.depth + 1;
    
    Element[2][] candidates;
    for (int a = 0; a < elements.length - 1; a++)
      for (int b = a + 1; b < elements.length; b++)
        candidates ~= [elements[a], elements[b]];
    
    auto splitHeuristic = function double (AABB first, AABB other) => 
      first.expanded(other).circumfence - first.circumfence - other.circumfence;
    
    auto bestPair = candidates.minPos!((firstPair, otherPair) => 
                      splitHeuristic(firstPair[0].aabb, firstPair[1].aabb) > 
                      splitHeuristic(otherPair[0].aabb, otherPair[1].aabb)).front;
    
    auto leftElements = elements.filter!(e => (bestPair[0].aabb.center - e.aabb.center).length < 
                                              (bestPair[1].aabb.center - e.aabb.center).length);
    auto rightElements = elements.filter!(e => (bestPair[1].aabb.center - e.aabb.center).length <= 
                                               (bestPair[0].aabb.center - e.aabb.center).length);
    
    leftElements.each!(element => leftNode.insert(element));
    rightElements.each!(element => rightNode.insert(element));
    
    elements.length = 0;
    childNodes = [leftNode, rightNode];
  }
  
  Element[] find(AABB box)
  {
    return elements.filter!(element => element.aabb.intersects(box)).array ~
                                       childNodes.map!(node => node.find(box)).join.array;
  }
  
  Element[2][] overlappingElements()
  {
    Element[2][] candidates;

    if (childNodes.length > 0)
      candidates ~= childNodes.map!(childNode => childNode.overlappingElements).join.array;
    
    if (elements.length > 0)
      for (int a = 0; a < elements.length - 1; a++)
        for (int b = a + 1; b < elements.length; b++)
          candidates ~= [elements[a], elements[b]];
    
    return candidates;
  }
  
  void populateLeveledBoxes(ref AABB[][int] leveledBoxes, int currentLevel = 0)
  {
    leveledBoxes[currentLevel] ~= aabb;
    childNodes.each!(childNode => childNode.populateLeveledBoxes(leveledBoxes, currentLevel + 1));
  }
}
