import '../annotations/module.dart';
import '../container/parrot_container.dart';
import '../container/parrot_token.dart';
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
  Future<T> get<T extends Object>(Type type) async {
    if (await hasProviderScope(type)) {
      return await container.get(TypedSymbol.create(type)).resolve() as T;
    }

    throw Exception(
        'The $type is not defined in the ${this.type} module providers or exports.');
  }

  @override
  Future<T> resolve<T extends Object>(Type type) {
    // TODO: implement resolve
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

  /// Has a provider scope in the module.
  ///
  /// 1. In the module providers.
  /// 2. In the module dependencies module exports.
  Future<bool> hasProviderScope(Type provider) async {
    // Check if the type is in the module providers.
    if (annotation.providers.contains(provider)) return true;

    // Check if the type is in the module dependencies module exports.
    for (final Type dependency in annotation.dependencies) {
      final ModuleContext context = await container
          .get<ModuleContext>(TypedSymbol.create(dependency))
          .resolve();

      if (await context.hasProviderExport(provider)) return true;
    }

    return false;
  }

  /// Has a provider export in the module.
  Future<bool> hasProviderExport(Type provider) async {
    for (final Type export in annotation.exports) {
      // Create the export symbol.
      final Symbol symbol = TypedSymbol.create(export);

      // If the export is a module.
      if (container.has(symbol)) {
        final ParrotToken token = container.get(symbol);

        if (token.type != ModuleContext) {
          continue;
        }

        final ModuleContext context = await token.resolve() as ModuleContext;
        if (await context.hasProviderExport(provider)) {
          return true;
        }
      }

      if (export == provider) return true;
    }

    final iterator = container.iterator;
    while (iterator.moveNext()) {
      if (iterator.current.type == ModuleContext) {
        final ModuleContext context =
            await iterator.current.resolve() as ModuleContext;
        if (context.annotation.global) {
          if (await context.hasProviderExport(provider)) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
