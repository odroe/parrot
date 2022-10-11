import 'package:parrot/src/container/instance_factory.dart';

import 'container/instance_context.dart';
import 'module_metadata.dart';
import 'module_ref.dart';

class ModuleContext<T> implements ModuleRef, InstanceContext<T> {
  ModuleContext({
    required this.metadata,
    required this.token,
    this.parent,
  });

  @override
  final Object token;

  @override
  late final InstanceFactory<T> factory;

  final ModuleMetadata metadata;
  final ModuleContext? parent;
  final Set<Object> aliases = {};

  @override
  Future<S> find<S>(Object token) {
    // TODO: implement find
    throw UnimplementedError();
  }

  @override
  Future<ModuleRef> select(Object token) {
    // TODO: implement select
    throw UnimplementedError();
  }

  @override
  void addAlias(Object alias) {
    if (!aliases.contains(alias)) {
      aliases.add(alias);
    }
  }

  @override
  bool equal(Object token) => this.token == token || aliases.contains(token);
}
