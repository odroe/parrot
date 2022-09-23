typedef NodeIdentifier = int;

abstract class Graph<T extends Node> {
  final Set<T> _nodes = const {};

  Set<T> get nodes => Set.unmodifiable(_nodes);

  final Map<T, Map<T, bool>> _inDegrees = const {};

  final Map<T, Map<T, bool>> _outDegrees = const {};

  Set<T> inDegrees(T node) {
    assert(_nodes.contains(node));

    return Set.unmodifiable(_inDegrees[node]!.keys);
  }

  Set<T> outDegrees(T node) {
    assert(_nodes.contains(node));

    return Set.unmodifiable(_outDegrees[node]!.keys);
  }

  void addNode(T node) {
    if (nodes.contains(node)) {
      return;
    }

    _nodes.add(node);
    _inDegrees[node] = {};
    _outDegrees[node] = {};
  }

  void removeNode(T node) {
    assert(_nodes.contains(node));

    for (final from in inDegrees(node)) {
      removeEdge(from, node);
    }
    for (final to in outDegrees(node)) {
      removeEdge(node, to);
    }
    _nodes.remove(node);
  }

  void replaceNode(T old, T node) {
    assert(_nodes.contains(old));

    addNode(node);
    for (final from in inDegrees(old)) {
      addEdge(from, node);
    }
    for (final to in outDegrees(old)) {
      addEdge(node, to);
    }
    removeNode(old);
  }

  void addEdge(T source, T destination) {
    assert(_nodes.contains(source));
    assert(_nodes.contains(destination));

    _inDegrees[destination]![source] = true;
    _outDegrees[source]![destination] = true;
  }

  void removeEdge(T source, T destination) {
    assert(_nodes.contains(source));
    assert(_nodes.contains(destination));

    _inDegrees[destination]!.remove(source);
    _outDegrees[source]!.remove(destination);
  }

  bool hasEdge(T source, T destination) {
    assert(_nodes.contains(source));
    assert(_nodes.contains(destination));

    return _outDegrees[source]!.containsKey(destination);
  }
}

abstract class Node {}
