import 'dart:mirrors';

import './mirror_utils.dart';

class ProviderDependencyTree {
  ProviderDependencyTree(this.provider, [this.parent]);

  final ProviderDependencyTree? parent;
  final Type provider;
  final List<ProviderDependencyTree> dependencies = [];

  // Returns dependency path.
  String toDependencyPath([String? end]) {
    final List<String> path = [];
    if (end != null) path.add(end);

    ProviderDependencyTree? dependency = this;
    while (dependency != null) {
      path.add(dependency.provider.toString());
      dependency = dependency.parent;
    }

    return path.reversed.join(' -> ');
  }
}

/// Find Provider Dependency Tree.
///
/// If a circular dependency occurs, an error is thrown.
Future<ProviderDependencyTree> buildProviderDependencyTree(
  ClassMirror provider,
  Symbol factoryName, [
  ProviderDependencyTree? parent,
]) async {
  ProviderDependencyTree? node = parent;
  while (node != null) {
    if (node.provider == provider.reflectedType) {
      throw Exception('''
Circular dependency detected:
    ${parent!.toDependencyPath(node.provider.toString())}

If your provider requires circular dependencies, use property-based injection：
    @Injectable()
    class A {
      @Inject() late final B b;
    }

    @Injectable()
    class B {
      @Inject() late final A a;
    }
''');
    }

    node = node.parent;
  }

  final ProviderDependencyTree dependencyTree =
      ProviderDependencyTree(provider.reflectedType, parent);

  // Find the factory method mirror.
  final MethodMirror factoryMirror = findFactoryMethod(provider, factoryName);

  // Get parameters iterator.
  final Iterator<ParameterMirror> iterator = factoryMirror.parameters.iterator;

  while (iterator.moveNext()) {
    final ParameterMirror parameter = iterator.current;

    if (parameter.type is ClassMirror) {
      final Type resolvedType = await resolveParameterType(parameter);
      final ClassMirror providerClassMirror = reflectClass(resolvedType);

      dependencyTree.dependencies.add(await buildProviderDependencyTree(
        providerClassMirror,
        resolveProviderFactoryName(providerClassMirror),
        dependencyTree,
      ));
      continue;
    }

    dependencyTree.dependencies.add(ProviderDependencyTree(
      parameter.type.reflectedType,
      dependencyTree,
    ));
  }

  return dependencyTree;
}
