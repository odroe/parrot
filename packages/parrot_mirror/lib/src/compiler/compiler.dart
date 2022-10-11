import 'dart:mirrors';

import 'package:parrot/parrot.dart';

abstract class Compiler implements ParrotCompiler {
  @override
  late ParrotApplication application;

  /// Returns current container.
  ParrotContainer get container => application.container;
}

Demo haha(a) => Demo();

class Demo {}

void main(List<String> args) {
  final ClosureMirror demo = reflect(haha) as ClosureMirror;

  print(demo.apply([1]).reflectee);
}
