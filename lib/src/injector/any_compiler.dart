import 'dart:mirrors';

import '../parrot_container.dart';
import 'any_compiler_runner.dart';

/// Any compiler.
///
/// This compiler is also used to compile custom annotations.
///
/// Core annotations are compiled by this compiler, E.g:
/// - [Inject]
/// - [Injectable]
/// - [Module]
///
/// Simple example:
/// ```dart
/// import 'package:parrot/parrot.dart';
///
/// class Simple extends AnyCompiler {
///   const SimpleCompiler();
///
///   @override
///   Future<void> compile(AnyCompilerRunner runner, Mirror mirror) async {
///     // If the mirror not a class mirror, return.
///     if (mirror is! ClassMirror) return;
///
///     runner.container[mirror.reflectedType] = mirror.newInstance(Symbol(''), []);
///   }
/// }
///
/// @Simple()
/// class MyClass {}
/// ```
abstract class AnyCompiler {
  const AnyCompiler();

  /// Other annotations this annotation depends on. Annotations that need to
  /// be depended on before calling this annotation have been completed.
  ///
  /// **Note** that this annotation will be compiled after the dependent,
  /// Dependent annotation must implement [AnyCompiler].
  Iterable<Type> get uses => const <Type>[];

  /// Compile the annotation.
  ///
  /// - [container]: The container is in current application.
  /// - [mirror]: The mirror of the annotated class.
  Future<void> compile(AnyCompilerRunner runner, Mirror mirror);
}
