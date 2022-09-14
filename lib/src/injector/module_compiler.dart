import 'dart:mirrors';

import '../annotations/module.dart';
import '../parrot_container.dart';
import 'any_compiler.dart';

mixin ModuleCompiler on ModuleAnnotation implements AnyCompiler {
  @override
  Future<void> compile(ParrotContainer container, Mirror mirror) async {
    if (mirror is! ClassMirror) {
      throw Exception('@Module() annotation must be used on a class.');
    }
  }
}
