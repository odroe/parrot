import 'container/parrot_container.dart';
import 'container/parrot_token.dart';
import 'injector/any_compiler_runner.dart';
import 'injector/module_context.dart';
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
  Future<void> initialize() async {
    // If the application has been initialized, throw an error.
    if (initialized) {
      throw Exception('The Parrot application has been initialized.');
    }

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
  late final ModuleContext context;

  @override
  T get<T extends Object>(Type type) => context.get<T>(type);

  @override
  T resolve<T extends Object>(Type type) => context.resolve<T>(type);

  @override
  ModuleContext select(Type module) => context.select(module);

  @override
  Future<void> initialize() async {
    // Create any compiler runner.
    final AnyCompilerRunner runner = AnyCompilerRunner(container);

    // Register any compiler runner to container.
    container.set(InstanceToken(AnyCompilerRunner, runner));

    // Run the module compiler.
    await runner.runAnyCompiler(module);

    // Set current context module.
    context = container.get(module)!.value;

    return super.initialize();
  }
}

/// 🦜 Parrot application.
class ParrotApplication extends ParrotApplicationBase
    with ParrotApplicationContext {
  ParrotApplication(super.module, {super.container}) {
    container.set(InstanceToken(ParrotApplication, this));
  }
}
