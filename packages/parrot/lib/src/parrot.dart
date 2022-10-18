library parrot.core.app;

import 'dart:async';

import '_internal/modular_tracker.dart';
import '_internal/module_container.dart';
import 'exception.dart';
import 'modular.dart';

part '_internal/parrot_impl.dart';

/// Parrot Application.
abstract class Parrot {
  /// Create a new [Parrot] application.
  factory Parrot(Module module) => _ParrotApplicationImpl(module);

  /// Root module reference.
  ModuleRef get ref;

  /// Select a module reference.
  ModuleRef select(Module module);

  /// Find an instance of a [Provider]
  ///
  /// @see [ModuleRef.call]
  FutureOr<T> find<T>(Provider<T> provider);

  /// Returns an instance of provider defined using providers that exist
  /// in any module.
  FutureOr<T> resolve<T>(Provider<T> provider);
}
