import 'dart:mirrors';

import 'any_compiler_runner.dart';

/// Any compiler.
///
/// This compiler is also used to compile custom annotations.
///
/// Core annotations are compiled by this compiler, E.g:
/// - [Injectable]
/// - [Module]
///
/// Simple example:
/// ```dart
/// import 'package:parrot/parrot.dart';
///
/// class Simple extends AnyCompiler<void> {
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
abstract class AnyCompiler<T> {
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
  Future<T> compile(AnyCompilerRunner runner, Mirror mirror);
}
