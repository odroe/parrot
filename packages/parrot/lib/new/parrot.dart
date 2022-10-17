library parrot.core.app;

import '_internal/modular_tracker.dart';
import '_internal/module_container.dart';
import 'exception.dart';
import 'modular.dart';

part '_internal/parrot_impl.dart';

/// Parrot Application.
abstract class Parrot {
  /// Create a new [Parrot] application.
  factory Parrot(Module module) => _ParrotApplicationImpl(module);

  /// Select a module reference.
  ModuleRef select(Module module);

  /// Find an instance of a [Provider]
  ///
  /// @see [ModuleRef.call]
  Future<T> find<T>(Provider<T> provider);

  /// Find a instance of a [Provider] with the given name.
  ///
  /// @see [ModuleRef.named]
  Future<T> findNamed<T>(Object name);

  /// Returns an instance of provider defined using providers that exist
  /// in any module.
  Future<T> resolve<T>(Provider<T> provider);

  /// Returns an instance of a provider with a name defined using
  /// providers that exists in any module.
  Future<T> resolveNamed<T>(Object name);
}
