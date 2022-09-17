import 'dart:mirrors';

import '../container/parrot_container.dart';
import '../parrot_context.dart';

/// Module Annotation.
///
/// This base annotation is used to define a module.
///
/// Together with `@Module`, the first-class citizen of the module, the data returned by [compoiler] will be written to [ModuleContext.metadata].
///
abstract class ModuleAnnotation<T extends ParrotContext> {
  /// Module mirror, generate a metadata.
  Future<T> compile(ParrotContainer container, ClassMirror mirror);
}
