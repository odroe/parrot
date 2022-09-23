import 'graph.dart';
import 'instance.dart';

class PlanGraph with Graph<PlanNode> {}

class PlanNode with Node {
  PlanNode({
    required this.instanceSpec,
  });

  final InstanceSpec instanceSpec;
}

Graph buildPlanGraph(List<InstanceSpec> instanceSpecs) {
  final graph = PlanGraph();

  for (var spec in instanceSpecs) {
    graph.addNode(PlanNode(instanceSpec: spec));
  }

  for (final source in graph.nodes) {
    for (final destination in graph.nodes) {
      for (final request in source.instanceSpec.constructorParams) {
        if (request.matchInstance(destination.instanceSpec)) {
          graph.addEdge(source, destination);
        }
      }
    }
  }

  return graph;
}
