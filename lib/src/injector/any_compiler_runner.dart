import 'package:meta/meta.dart';

import 'any_compiler.dart';

abstract class AnyCompilerRunner {
  /// Run all [AnyCompiler] compile annotations.
  @internal
  Future<void> runAnyCompiler(Type type);
}
