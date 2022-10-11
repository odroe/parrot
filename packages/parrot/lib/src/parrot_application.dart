import 'parrot_compiler.dart';
import 'container/parrot_container.dart';

/// Parrot application.
abstract class ParrotApplication {
  /// Create a new application.
  factory ParrotApplication(Object module) = _ParrotApplicationImpl;

  /// The app binding module.
  abstract final Object module;

  /// Returns the compiler.
  ParrotCompiler get compiler;

  /// Returns the app binding conatiner.
  ParrotContainer get container;

  /// Initialize the application.
  Future<void> initialize(ParrotCompiler compiler);
}

/// Parrot application implementation.
class _ParrotApplicationImpl implements ParrotApplication {
  _ParrotApplicationImpl(this.module);

  @override
  final Object module;

  @override
  late final ParrotCompiler compiler;

  @override
  ParrotContainer container = ParrotContainer();

  @override
  Future<void> initialize(ParrotCompiler compiler) async {
    this.compiler = compiler;
    compiler.application = this;

    await compiler.compileModule(module);
  }
}
