import '../injector/any_compiler.dart';
import '../injector/module_compiler.dart';

abstract class ModuleAnnotation extends AnyCompiler {
  const ModuleAnnotation({
    this.dependencies = const [],
    this.providers = const [],
    this.exports = const [],
    this.global = false,
  });

  /// The module registed service providers.
  final Iterable<Type> providers;

  /// The module dependency modules.
  final Iterable<Type> dependencies;

  /// Exported providers and dependencies.
  final Iterable<Type> exports;

  /// The module is global.
  final bool global;
}

/// Parrot module annotation.
///
/// A module is a class that contains bindings.
///
/// Example:
/// ```dart
/// @Module(
///   dependencies: [ModuleA, ModuleB],
/// )
/// class AppModule {}
///
/// final app = ParrotApplication(AppModule);
/// ```
class Module = ModuleAnnotation with ModuleCompiler;
