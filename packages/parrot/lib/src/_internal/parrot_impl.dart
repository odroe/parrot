part of parrot.core.app;

/// Parrot Application implementation.
class _ParrotApplicationImpl implements Parrot {
  /// Creates a new [_ParrotApplicationImpl] instance.
  const _ParrotApplicationImpl._internal(this.tracker);

  /// Create a new [_ParrotApplicationImpl] instance
  ///
  /// Parses the given [module] and creates a new [_ParrotApplicationImpl]
  /// instance.
  factory _ParrotApplicationImpl(Module module) {
    // Create a module container.
    final ModuleConatiner container = ModuleConatiner();

    // Create a module tracker.
    final ModularTracker tracker = ModularTracker.lookup(
      module: module,
      container: container,
    );

    // Create and return a new application.
    return _ParrotApplicationImpl._internal(tracker);
  }

  /// Root module tracker.
  final ModularTracker tracker;

  @override
  ModuleRef get ref => tracker;

  @override
  Future<T> find<T>(Provider<T> provider) async => ref(provider);

  @override
  ModuleRef select(Module module) {
    // If the module is same as current module, return the current tracker.
    if (module == tracker.module) return tracker;

    // Returns the [ModularTracker] in module container.
    // If the module is not found, throws a [ParrotModuleNotFoundException].
    return tracker.container.get(module);
  }

  @override
  Future<T> resolve<T>(Provider<T> provider) async {
    final Module? selected = _findModuleThatDefinedProvider(tracker, provider);

    // If the module is not found, throws a [ParrotProviderNotFoundException].
    if (selected == null) {
      throw ParrotProviderNotFoundException(provider, tracker.module);
    }

    final ModuleRef ref =
        ModularTracker.lookup(module: selected, container: tracker.container);

    return ref<T>(provider);
  }

  /// Find a module that defined the given [provider].
  static Module? _findModuleThatDefinedProvider<T>(
      ModularTracker tracker, Provider<T> provider) {
    // Has the provider defined in tracker?
    if (tracker.hasProviderDefined(provider)) return tracker.module;

    // Find module in imported modules.
    for (final Module imported in tracker.module.imports) {
      final ModularTracker importedTracker =
          ModularTracker.lookup(module: imported, container: tracker.container);
      final Module? result =
          _findModuleThatDefinedProvider(importedTracker, provider);

      if (result != null) return result;
    }

    // Not found.
    return null;
  }
}
