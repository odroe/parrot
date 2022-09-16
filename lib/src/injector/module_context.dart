import '../annotations/module.dart';
import '../container/parrot_container.dart';
import '../parrot_context.dart';
import '../utils/typed_symbol.dart';

class ModuleContext implements ParrotContext {
  ModuleContext({
    required this.container,
    required this.type,
    required this.annotation,
  });

  /// Current module annotation instance.
  final Module annotation;

  /// Parrot container.
  final ParrotContainer container;

  /// Current context module.
  final Type type;

  /// Metadata for other annotations of the module.
  final List<ParrotContext> metadata = [];

  @override
  Future<T> get<T extends Object>(Type type) {
    throw UnimplementedError();
  }

  @override
  Future<T> resolve<T extends Object>(Type type) {
    throw UnimplementedError();
  }

  @override
  Future<ModuleContext> select(Type module) async {
    // If module is the same as the current module, return the current context.
    if (module == type) return this;

    // Find the module in dependencies.
    for (final Type dependency in annotation.dependencies) {
      try {
        final ModuleContext context = await container
            .get<ModuleContext>(TypedSymbol.create(dependency))
            .resolve();

        // If the module is found, return the context.
        return context.select(module);
      } catch (e) {
        // Ignore the error.
        continue;
      }
    }

    return container
        .get<ModuleContext>(TypedSymbol.create(module))
        .resolve()
        .onError((error, stackTrace) =>
            throw Exception('The module $module is not found.'));
  }
}
