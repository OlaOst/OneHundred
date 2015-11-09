module spatialindex.rtree;

import std.algorithm;
import std.range;

import gl3n.aabb;

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
    {
      aabb = element.aabb;
      aabb.min.z = -1.0;
      aabb.max.z = 1.0;
    }
    else
    {
      aabb.expand(element.aabb);
    }
    
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
    leftNode.depth = this.depth + 1;
    rightNode.depth = this.depth + 1;
    
    //auto candidates = cartesianProduct(elements, elements).filter!(elementPair => elementPair[0].id != elementPair[1].id);
    Element[2][] candidates;
    for (int a = 0; a < elements.length - 1; a++)
      for (int b = a + 1; b < elements.length; b++)
        candidates ~= [elements[a], elements[b]];
    
    auto bestPair = candidates.minPos!((firstPair, otherPair) => splitHeuristic(firstPair[0].aabb, firstPair[1].aabb) > splitHeuristic(otherPair[0].aabb, otherPair[1].aabb)).front;

    auto leftElements = elements.filter!(element => (bestPair[0].aabb.center - element.aabb.center).length < (bestPair[1].aabb.center - element.aabb.center).length);
    auto rightElements = elements.filter!(element => (bestPair[1].aabb.center - element.aabb.center).length <= (bestPair[0].aabb.center - element.aabb.center).length);
    
    scope(failure)
    {
      import std.stdio;
      writeln("split failed, bestPair ", bestPair[0].aabb, ", ", bestPair[1].aabb);
      writeln("all candidates: ");
      candidates.each!(candidate => writeln(candidate[0].aabb, ", ", candidate[1].aabb, " => ", splitHeuristic(candidate[0].aabb, candidate[1].aabb)));
      
      writeln("left elements: ");
      leftElements.each!(element => writeln(element.aabb));
      writeln("right elements: ");
      rightElements.each!(element => writeln(element.aabb));
    }
    
    assert(leftElements.canFind(bestPair[0]));
    assert(rightElements.canFind(bestPair[1]));
    
    assert(!leftElements.empty && leftElements.array.length < maxElements);
    assert(!rightElements.empty && rightElements.array.length < maxElements);
    
    leftElements.each!(element => leftNode.insert(element));
    rightElements.each!(element => rightNode.insert(element));
    
    elements.length = 0;
    childNodes = [leftNode, rightNode];
  }
  
  Element[] find(AABB aabb)
  {
    import std.stdio;
    //writeln("searchBox ", aabb, " intersecting node with depth ", depth, " and nodebox ", this.aabb, ": ", aabb.intersects(this.aabb));
    
    return (aabb.intersectsEquals(this.aabb)) ? elements ~ childNodes.map!(childNode => childNode.find(aabb)).join.array : null;
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

double splitHeuristic(AABB first, AABB other)
{
  //return first.expanded(other).area - first.area - other.area;
  //return first.expanded(other).area;
  
  return first.expanded(other).circumfence - first.circumfence - other.circumfence;
  //return first.expanded(other).circumfence;
}
