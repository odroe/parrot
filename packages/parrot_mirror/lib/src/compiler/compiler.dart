import 'package:parrot/parrot.dart';

abstract class Compiler implements ParrotCompiler {
  @override
  late ParrotApplication application;

  /// Returns current container.
  ParrotContainer get container => application.container;
}
