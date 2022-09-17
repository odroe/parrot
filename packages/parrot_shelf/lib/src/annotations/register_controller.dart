import 'dart:mirrors';

import 'package:parrot/parrot.dart';

/// Register controller annotation.
///
/// This annotation is used to register the controllers in the module.
///
/// Example:
/// ```dart
/// @RegisterController([MyController])
/// @Module()
/// class MyModule extends Module {}
///
/// @Controller()
/// class MyController {
///   @Get('/')
///   String get() => 'Hello, 🦜 Parrot!';
/// }
/// ```
class RegisterController implements ModuleAnnotation {
  const RegisterController(this.controllers);

  final List<Type> controllers;

  @override
  Future<ParrotContext> compile(ParrotContainer container, ClassMirror mirror) {
    // TODO: implement compile
    throw UnimplementedError();
  }
}
