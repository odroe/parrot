import 'package:parrot/src/scope.dart';

import 'instance_definition.dart';
import 'instance_finder.dart';
import 'module_annotation.dart';

abstract class ModuleInstanceSetter<T> {
  set instance(T instance);
}

/// Module definition.
abstract class ModuleDefinition<T>
    implements InstanceDefinition<T>, InstanceFinder {
  factory ModuleDefinition({
    required Module annotation,
    required Object identifier,
    ModuleDefinition parent,
  }) = _ModuleDefinitionImpl;

  /// Module annotation.
  Module get annotation;

  /// Parent module definition.
  ModuleDefinition? get parent;

  /// Add a dependent module definition.
  void addDependency(ModuleDefinition moduleDefinition);

  /// Add a provider.
  void addProvider(InstanceDefinition instanceDefinition, [Object? inquirer]);
}

class _ModuleDefinitionImpl<T>
    implements ModuleDefinition<T>, ModuleInstanceSetter<T> {
  _ModuleDefinitionImpl({
    required this.annotation,
    required this.identifier,
    this.parent,
  });

  @override
  final Module annotation;

  @override
  final Object identifier;

  @override
  late final T instance;

  @override
  final ModuleDefinition? parent;

  @override
  Scope get scope => Scope.singleton;

  @override
  InstanceDefinition find(Object identifier, [Object? inquirer]) {
    // TODO: implement find
    throw UnimplementedError();
  }

  @override
  // TODO: implement dependencies
  Iterable<ModuleDefinition> get dependencies => throw UnimplementedError();

  @override
  void addDependency(ModuleDefinition moduleDefinition) {
    // TODO: implement addDependency
  }

  @override
  void addProvider(InstanceDefinition instanceDefinition, [Object? inquirer]) {
    // TODO: implement addProvider
  }
}
