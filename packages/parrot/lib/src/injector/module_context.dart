import '../annotations/module.dart';
import '../container/parrot_container.dart';
import '../container/parrot_token.dart';
import '../parrot_context.dart';
import '../utils/typed_symbol.dart';
import 'provider_context.dart';

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

  @override
  Future<T> get<T extends Object>(Type type) async {
    if (await hasProviderScope(type)) {
      return await container.get(TypedSymbol.create(type)).resolve() as T;
    }

    throw Exception(
        'The $type is not defined in the ${this.type} module providers or exports.');
  }

  @override
  Future<T> resolve<T extends Object>(Type type) async {
    if (await hasProviderDefinition(type) ||
        await hasProviderDefinitionInGlobal(type)) {
      return await container.get(TypedSymbol.create(type)).resolve() as T;
    }

    throw Exception('The $type is not defined in the ${this.type} module.');
  }

  /// Has a provider defined.
  Future<bool> hasProviderDefinition(Type provider) async {
    if (annotation.providers.contains(provider)) return true;
    for (final Type dependency in annotation.dependencies) {
      final ModuleContext context = await container
          .get<ModuleContext>(TypedSymbol.create(dependency))
          .resolve();
      if (await context.hasProviderDefinition(provider)) return true;
    }

    return false;
  }

  /// has a provider defined in global modules
  Future<bool> hasProviderDefinitionInGlobal(Type provider) async {
    // Get all module context token.
    final iterator =
        container.where((element) => element.type == ModuleContext).iterator;
    while (iterator.moveNext()) {
      final ModuleContext context =
          await iterator.current.resolve() as ModuleContext;
      if (context.annotation.global &&
          await context.hasProviderDefinition(provider)) {
        return true;
      }
    }

    return false;
  }

  /// Has a provider scope in the module.
  ///
  /// 1. Defined in the module providers.
  /// 2. In the module exported.
  /// 3. In global modules exported.
  Future<bool> hasProviderScope(Type provider) async {
    // Check if the type is in the module providers.
    if (annotation.providers.contains(provider)) return true;

    // Check if the type is in the module dependencies module exports.
    for (final Type dependency in annotation.dependencies) {
      final ModuleContext context = await container
          .get<ModuleContext>(TypedSymbol.create(dependency))
          .resolve();

      if (await context.hasExport(provider)) return true;
    }

    // If the privider export in global module exports.
    return hasProviderInGlobalExport(provider);
  }

  /// Has a provider export in the module.
  Future<bool> hasExport(Type provider) async {
    for (final Type export in annotation.exports) {
      if (export == provider) return true;

      // Create the export symbol.
      final Symbol symbol = TypedSymbol.create(export);

      // If token not registered, continue.
      if (!container.has(symbol)) continue;

      // Get parrot token.
      final ParrotToken token = container.get(symbol);

      // If the token is ProviderContext, and type is provider, return true.
      if (token is ProviderContext && token.type == provider) {
        return true;
      }

      // If token type is not ModuleContext, continue.
      if (token.type != ModuleContext) continue;

      // Get module context.
      final ModuleContext context = await token.resolve() as ModuleContext;

      // If the module context has provider export, return true.
      if (await context.hasExport(provider)) {
        return true;
      }
    }

    return false;
  }

  /// Has a provider export in global modules.
  Future<bool> hasProviderInGlobalExport(Type provider) async {
    // Get all module context token.
    final iterator =
        container.where((element) => element.type == ModuleContext).iterator;

    // Iterate all module context token.
    while (iterator.moveNext()) {
      // Get module context.
      final ModuleContext context =
          await iterator.current.resolve() as ModuleContext;

      // If the module context is
      if (context.annotation.global && await context.hasExport(provider)) {
        return true;
      }
    }

    return false;
  }
}
