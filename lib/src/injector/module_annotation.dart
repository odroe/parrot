import 'dart:mirrors';

import 'parrot_container.dart';

/// Module Annotation.
///
/// This base annotation is used to define a module.
///
/// Together with `@Module`, the first-class citizen of the module, the data returned by [compoiler] will be written to [ModuleContext.metadata].
///
abstract class ModuleAnnotation<T> {
  /// Module mirror, generate a metadata.
  Future<T> compile(ParrotContainer container, ClassMirror mirror);
}
