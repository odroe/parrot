import 'injectable_annotation.dart';
import 'module_metadata.dart';

/// Module annotation.
class Module extends ModuleMetadata implements Injectable {
  /// Create a new [Module] instance.
  const Module({
    super.dependencies,
    super.exports,
    super.global,
    super.providers,
    this.factory,
  });

  /// The module class constructor or factory.
  ///
  /// Defaults to the default constructor.
  @override
  final Function? factory;
}
