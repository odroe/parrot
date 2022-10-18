import 'dart:async';

import '../exception.dart';
import '../modular.dart';
import 'module_container.dart';

/// Modular tracker.
class ModularTracker implements ModuleRef {
  ModularTracker._internal({
    required this.module,
    required this.container,
  });

  /// Lookup a [ModularTracker] instance.
  ///
  /// If the [ModularTracker] is registered in the [ModuleContainer],
  /// returns the [ModularTracker] instance.
  ///
  /// Otherwise, creates a new [ModularTracker] instance and registers it
  /// in the [ModuleConatiner].
  factory ModularTracker.lookup({
    required Module module,
    required ModuleConatiner container,
  }) {
    // If the module is already registered, return the registered module.
    if (container.has(module)) return container.get(module);

    // Create a new tracker.
    final ModularTracker tracker = ModularTracker._internal(
      module: module,
      container: container,
    );

    // Register the module to the container.
    container.register(tracker);

    // Return the tracker.
    return tracker;
  }

  /// Current tracker module.
  final Module module;

  /// Module container.
  final ModuleConatiner container;

  /// Provider result store.
  final Map<Provider, FutureOr> _store = {};

  @override
  FutureOr<T> call<T>(Provider<T> provider) {
    // Has the provider been defined?
    if (hasProviderDefined(provider)) {
      return callDefinedProvider(provider);
    }

    // Find the module that exports this provider.
    for (final Module imported in module.imports) {
      final ModularTracker tracker =
          ModularTracker.lookup(module: imported, container: container);

      // If the provider is exported, call exported provider.
      if (tracker.hasProviderExported(provider)) {
        return tracker.callExportedProvider(provider);
      }
    }

    throw ParrotProviderNotFoundException(provider, module);
  }

  /// Has a [provider] been defined?
  bool hasProviderDefined<T>(Provider<T> provider) =>
      module.providers.any((element) => element == provider);

  /// Has the [provider] been exported?
  bool hasProviderExported<T>(Provider<T> provider) =>
      findModuleThatExportedProvider(provider) != null;

  /// Calls defined provider.
  ///
  /// If the [provider] is stored result [FutureOr], returns the result.
  /// Otherwise, create the [provider] and stores the result.
  FutureOr<T> callDefinedProvider<T>(Provider<T> provider) {
    // Has the provider been defined?
    if (!hasProviderDefined<T>(provider)) {
      throw ParrotProviderNotFoundException(provider, module);
    }

    /// Returns or creates the provider result.
    return (_store[provider] ??= provider(this)) as FutureOr<T>;
  }

  /// Calls exported provider.
  FutureOr<T> callExportedProvider<T>(Provider<T> provider) {
    // Find the module that exports this provider.
    final Module? exported = findModuleThatExportedProvider(provider);

    // If the module is not found, throws a [ParrotProviderNotFoundException].
    if (exported == null) {
      throw ParrotProviderNotFoundException(provider, module);
    }

    // Create a tracker for the exported module.
    final ModularTracker tracker =
        ModularTracker.lookup(module: exported, container: container);

    // Call the exported provider.
    return tracker.callDefinedProvider<T>(provider);
  }

  /// Find the module that exports the [provider].
  Module? findModuleThatExportedProvider<T>(Provider<T> provider) {
    for (final Object exported in module.exports) {
      // If exported is a [Module].
      if (exported is Module) {
        final ModularTracker tracker =
            ModularTracker.lookup(module: exported, container: container);

        final Module? result = tracker.findModuleThatExportedProvider(provider);
        if (result != null) return result;

        // If the provider is exported, return true.
      } else if ((exported as Provider) == provider) {
        return module;
      }
    }

    return null;
  }
}
