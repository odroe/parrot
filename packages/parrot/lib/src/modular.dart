import 'dart:async';

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
class Module {
  /// Create a new [Module] definition instance.
  const Module({
    this.providers = const {},
    this.imports = const {},
    this.exports = const {},
  });

  /// Imported modules.
  final Set<Module> imports;

  /// The module providers.
  final Set<Provider> providers;

  /// Exported modules or providers.
  final Set<Object> exports;
}
