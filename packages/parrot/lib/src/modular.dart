library parrot.core.modular;

import 'dart:async';

part '_internal/module_impl.dart';

/// Module provider.
///
/// A provider is a function that returns a value.
///
/// ```dart
/// final Provider<String> hello = (ref) => 'Hello World!';
/// final module = Module(
///   providers: { hello },
/// );
/// ```
typedef Provider<T> = FutureOr<T> Function(ModuleRef ref);

/// Module reference.
///
/// The reference method of the current module, through call to obtain
/// providers in the current module (except itself) or exported providers
/// in other imported modules.
///
/// ## Basic
/// ```dart
/// final Provider<String> hello = (ref) => 'Hello';
/// final Provider<String> world = (ref) async => '${await ref(hello)} World!';
/// final module = Module(
///   providers: { hello, world },
/// );
/// ```
abstract class ModuleRef {
  /// Returns a provider result from the current module.
  ///
  /// Only providers in the current module (except itself) or exported providers
  /// in other imported modules can be obtained.
  FutureOr<T> call<T>(Provider<T> provider);
}

/// Module definition.
abstract class Module {
  /// Creates a new [Module] instance.
  factory Module({
    Set<Module> imports,
    Set<Provider> providers,
    Set<Object> exports,
  }) = _ModuleImpl;

  /// Imported modules.
  Set<Module> get imports;

  /// The module providers.
  Set<Provider> get providers;

  /// Exported modules or providers.
  Set<Object> get exports;
}
