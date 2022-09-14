import 'package:meta/meta.dart';

import 'injector/module_context.dart';
import 'injector/parrot_application_any_compiler_runner.dart';
import 'parrot_container.dart';
import 'parrot_context.dart';

/// 🦜 Parrot application base class.
abstract class ParrotApplicationBase implements ParrotContext {
  ParrotApplicationBase(
    this.module, {
    ParrotContainer? container,
  }) {
    this.container = container ?? ParrotContainer();
  }

  /// The application container.
  late final ParrotContainer container;

  /// Current Parrot application module.
  final Type module;

  /// The application has been initialized.
  bool get initialized => _initialized;

  /// Run [initialize] method set [initialized] to true.
  bool _initialized = false;

  /// Initialize the application.
  @mustCallSuper
  Future<void> initialize() async {
    // If the application has been initialized, throw an error.
    if (initialized) {
      throw Exception('The Parrot application has been initialized.');
    }

    // Register the application to container.
    container.putIfAbsent(ParrotApplication, () => this);

    // Set initialized to true.
    _initialized = true;
  }
}

/// Implementation [ParrotContext] interface for [ParrotApplicationBase].
///
/// Module for proxying root node.
mixin ParrotApplicationContext on ParrotApplicationBase
    implements ParrotContext {
  /// Current context module.
  @internal
  late final ModuleContext context;

  @override
  T get<T extends Object>(Type type) => context.get<T>(type);

  @override
  T resolve<T extends Object>(Type type) => context.resolve<T>(type);

  @override
  ModuleContext select(Type module) => context.select(module);
}

class ParrotApplication = ParrotApplicationBase
    with ParrotApplicationContext, ParrotApplicationAnyCompilerRunner;

// class _ParrotApplicationImpl
//     with AnyCompilerRunner
//     implements ParrotApplication {
//   _ParrotApplicationImpl._({
//     required this.container,
//     required this.module,
//   });

//   factory _ParrotApplicationImpl(
//     Type module, {
//     ParrotContainer? container,
//   }) {
//     final ParrotContainer resolvedContainer = container ?? ParrotContainer();
//     final _ParrotApplicationImpl app = _ParrotApplicationImpl._(
//       container: resolvedContainer,
//       module: module,
//     );

//     // Add the application to the container.
//     resolvedContainer[ParrotApplication] = app;

//     return app;
//   }

//   @override
//   final ParrotContainer container;

//   /// The application root module.
//   final Type module;

//   /// Get the root module context.
//   ParrotContext get root => container[module]!;

//   @override
//   T get<T extends Object>(Type type) => root.get<T>(type);

//   @override
//   ModuleContext select(Type module) => root.select(module);

//   @override
//   T resolve<T extends Object>(Type type) => root.resolve<T>(type);
// }
