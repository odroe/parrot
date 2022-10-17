library parrot.core.modular;

import 'dart:async';

part '_internal/module_impl.dart';
part '_internal/named_provider_impl.dart';

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

/// Module named provider.
abstract class NamedProvider<T> {
  /// @see [ProviderExtension.name]
  Object get name;

  /// Super [Provider].
  Provider<T> get provider;

  /// @see [ProviderExtension.named]
  Provider<T> named(Object name);

  /// Calls super [Provider].
  FutureOr<T> call(ModuleRef ref);
}

/// Provider function extension.
extension ProviderExtension<T> on Provider<T> {
  /// Returns the provider name.
  Object get name => this;

  /// Returns the provider with the given name.
  Provider<T> named(Object name) => _NamedProviderImpl(name, this);
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
///
/// ## Named
/// ```dart
/// final Provider<String> hello = (ref) => 'Hello';
/// final Provider<String> world = (ref) async => '${await ref.named(#name)} World!';
/// final module = Module(
///   providers: { hello.named(#name), world },
/// );
/// ```
abstract class ModuleRef {
  /// Returns a provider result from the current module.
  ///
  /// Only providers in the current module (except itself) or exported providers
  /// in other imported modules can be obtained.
  FutureOr<T> call<T>(Provider<T> provider);

  /// Returns a named provider result from the current module.
  ///
  /// @see [call]
  FutureOr<T> named<T>(Object name);
}
