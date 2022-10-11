import 'package:parrot/src/container/instance_factory.dart';

import 'container/instance_context.dart';
import 'container/parrot_container.dart';
import 'dynamic_module.dart';
import 'module_metadata.dart';
import 'module_ref.dart';
import 'provider.dart';

class ModuleContext<T> implements ModuleRef, InstanceContext<T> {
  ModuleContext({
    required this.metadata,
    required this.token,
    required ParrotContainer container,
    this.parent,
  }) : _container = container;

  @override
  final Object token;

  @override
  late final InstanceFactory<T> factory;

  final ParrotContainer _container;
  final ModuleMetadata metadata;
  final ModuleContext? parent;
  final Set<Object> aliases = {};

  @override
  void addAlias(Object alias) {
    if (!aliases.contains(alias)) {
      aliases.add(alias);
    }
  }

  @override
  bool equal(Object token) => this.token == token || aliases.contains(token);

  @override
  ModuleRef select(Object module) {
    final ModuleContext? context =
        selectDependencyModule(token) ?? selectGlobalModule(module);

    // If context is not null, return it.
    if (context != null) return context;

    // Throw error.
    throw StateError('Module not found: $module');
  }

  @override
  Future<S> find<S>(Object provider) {
    final InstanceContext<S>? context = findDefinitionProvider<S>(provider) ??
        findExportedProvider<S>(provider);

    // If context is not null, return it.
    if (context != null) return _container.getInstance(context.token);

    // Throw error.
    throw StateError('Provider not found: $provider');
  }

  /// Find exported provider.
  InstanceContext<S>? findExportedProvider<S>(Object provider) {
    for (final Object exported in metadata.exports) {
      // Resolve token.
      final Object token = exported is DynamicModule
          ? exported.module
          : exported is Provider
              ? exported.token
              : exported;

      // If token has not been registered, continue.
      if (!_container.has(token)) continue;

      // Find instance context.
      final InstanceContext context = _container.getInstanceContext(token);

      // If token is context, return it.
      if (context.equal(provider)) return context as InstanceContext<S>;

      // If context is a [ModuleContext], find in module exports.
      if (context is ModuleContext) {
        final InstanceContext<S>? instanceContext =
            context.findExportedProvider<S>(provider);

        // If instance context is not null, return it.
        if (instanceContext != null) return instanceContext;
      }
    }

    return null;
  }

  /// Find definition provider.
  InstanceContext<S>? findDefinitionProvider<S>(Object provider) {
    // If provider is self, return self.
    if (equal(provider)) return this as InstanceContext<S>;

    for (final Object definition in metadata.providers) {
      if (definition == provider ||
          (definition is Provider && definition.token == provider)) {
        return _container
            .getInstanceContext<S>(provider is Provider ? token : provider);
      }
    }

    return null;
  }

  /// Select global module.
  ModuleContext<S>? selectGlobalModule<S>(Object module) {
    // Find all global modules.
    final Iterable<ModuleContext> globalModules = _container
        .whereType<ModuleContext>()
        .where((element) => element.metadata.global);

    for (final ModuleContext context in globalModules) {
      if (context.equal(module)) return context as ModuleContext<S>;
    }

    return null;
  }

  /// Select dependency module.
  ModuleContext<S>? selectDependencyModule<S>(Object module) {
    // If token is self, return self.
    if (equal(module)) return this as ModuleContext<S>;

    for (final Object dependency in metadata.dependencies) {
      if (_container.has(dependency)) {
        final InstanceContext context =
            _container.getInstanceContext(dependency);

        // If context is not [ModuleContext], continue.
        if (context is! ModuleContext) continue;

        final ModuleContext? moduleContext =
            context.selectDependencyModule(module);

        // If module context is not null, return it.
        if (moduleContext != null) return moduleContext as ModuleContext<S>;
      }
    }

    return null;
  }

  @override
  ModuleContext<S> cast<S>() {
    if (this is ModuleContext<S>) return this as ModuleContext<S>;

    final ModuleContext<S> context = ModuleContext<S>(
      metadata: metadata,
      token: token,
      container: _container,
      parent: parent,
    );

    context.factory = () async {
      final T instance = await factory();

      return instance as S;
    };

    context.aliases.addAll(aliases);

    return context;
  }
}
