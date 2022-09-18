import 'dart:mirrors';

import 'package:parrot/src/injector/module_context.dart';

import '../annotations/injectable.dart';
import '../container/parrot_container.dart';
import '../container/parrot_token.dart';
import '../utils/typed_symbol.dart';
import 'internal/dependency_tree.dart';
import 'internal/mirror_utils.dart';
import 'provider_context.dart';
import 'scope.dart';

typedef ProviderFactory = Future<Object> Function();

class ProviderCompiler {
  const ProviderCompiler(this.container);

  final ParrotContainer container;

  /// Compile all providers.
  Future<void> compile() async {
    final Iterator<ParrotToken<ModuleContext>> iterator =
        container.whereType<ParrotToken<ModuleContext>>().iterator;

    while (iterator.moveNext()) {
      final ModuleContext module = await iterator.current.resolve();

      for (final Type provider in module.annotation.providers) {
        await compileProvider(module, provider);
      }
    }
  }

  /// Compile a provider.
  Future<ProviderContext> compileProvider(
      ModuleContext module, Type provider) async {
    final ClassMirror classMirror = reflectClass(provider);

    // Get the provider all injectable annotations.
    final List<Injectable> annotations = classMirror.metadata
        .where((InstanceMirror instance) => instance.reflectee is Injectable)
        .map<Injectable>((InstanceMirror instance) => instance.reflectee)
        .toList();

    // If annotations is not equal to 1, throw an error.
    if (annotations.length != 1) {
      throw Exception(
          'The provider $provider must have exactly one `@Injectable()` annotation.');
    }

    // Create the provider symbol.
    final Symbol symbol = TypedSymbol.create(provider);

    // If the provider is compiled return it.
    if (container.has(symbol)) {
      return container.get(symbol) as ProviderContext;
    }

    // Create the provider context.
    final ProviderContext context =
        await createProviderContext(module, classMirror, annotations.first);

    // Add the provider context to the container.
    container.register(context);

    return context;
  }

  /// Create a provider context.
  Future<ProviderContext> createProviderContext(ModuleContext module,
      ClassMirror classMirror, Injectable annotation) async {
    final TransientProviderContext context =
        await createTransientProviderContext(
            module, classMirror, annotation.factory);

    // If the provider is a singleton, create a singleton provider context.
    if (annotation.scope == Scope.singleton) {
      return SingletonProviderContext(
        modules: context.modules,
        type: context.type,
        instance: await context.resolve(),
      );
    }

    return context;
  }

  /// Create a [TransientProviderContext].
  Future<TransientProviderContext> createTransientProviderContext(
    ModuleContext module,
    ClassMirror classMirror,
    Symbol factoryName,
  ) async {
    final MethodMirror factoryMirror =
        findFactoryMethod(classMirror, factoryName);

    // Check circular dependencies.
    // Using [findProviderDependencyTree] to check circular dependencies.
    // Because the method of circular dependency will throw an error.
    buildProviderDependencyTree(classMirror, factoryName);

    final resolvedArguments =
        await resolveArguments(module, factoryMirror.parameters);

    return TransientProviderContext(
      modules: await findProviderOwnerModules(classMirror),
      type: classMirror.reflectedType,
      factory:
          buildProviderFactory(resolvedArguments, classMirror, factoryMirror),
    );
  }

  ProviderFactory buildProviderFactory(
    List<ResolvedArgument> resolvedArguments,
    ClassMirror classMirror,
    MethodMirror factoryMirror,
  ) {
    // Create the provider factory.
    Future<Object> resolve() async {
      final List resolvedPositionalArguments = await Future.wait(
        resolvedArguments
            .where((resolved) => _isPositionalArgument(resolved.mirror))
            .map((resolved) async => resolved.token?.resolve()),
      );

      final Map<Symbol, Object?> resolvedNamedArguments = Map.fromEntries(
        await Future.wait(
          resolvedArguments
              .where((resolved) => _isNamedArgument(resolved.mirror))
              .map((resolved) async => MapEntry(
                    _getArgumentName(resolved.mirror),
                    await resolved.token?.resolve(),
                  )),
        ),
      );

      return classMirror
          .newInstance(
            factoryMirror.constructorName,
            resolvedPositionalArguments,
            resolvedNamedArguments,
          )
          .reflectee;
    }

    return resolve;
  }

  /// Resolve arguments.
  Future<List<ResolvedArgument>> resolveArguments(
    ModuleContext module,
    List<ParameterMirror> parameters,
  ) async {
    final Iterator<ParameterMirror> iterator = parameters.iterator;

    final List<ResolvedArgument> resolved = [];
    while (iterator.moveNext()) {
      resolved.add(ResolvedArgument(
          iterator.current, await compileArgument(module, iterator.current)));
    }

    return resolved;
  }

  bool _isPositionalArgument(ParameterMirror mirror) {
    return !mirror.isNamed;
  }

  bool _isNamedArgument(ParameterMirror mirror) {
    return mirror.isNamed;
  }

  Symbol _getArgumentName(ParameterMirror mirror) {
    return mirror.simpleName;
  }

  /// Find provider owner modules.
  Future<List<Type>> findProviderOwnerModules(ClassMirror classMirror) async {
    final List<Type> modules = [];
    final Iterator<ParrotToken> iterator = container.iterator;
    while (iterator.moveNext()) {
      final ParrotToken token = iterator.current;
      if (token is ParrotToken<ModuleContext>) {
        final ModuleContext module = await token.resolve();
        if (module.annotation.providers.contains(classMirror.reflectedType)) {
          modules.add(module.type);
        }
      }
    }

    return modules;
  }

  /// Compile argument.
  Future<ParrotToken?> compileArgument(
    ModuleContext module,
    ParameterMirror parameter,
  ) async {
    final Type provider = await resolveParameterType(parameter);
    final ClassMirror classMirror = reflectClass(provider);

    if (parameter.type.reflectedType == null.runtimeType) {
      return null;
    } else if (hasInjectableAnnotation(classMirror)) {
      // Check the parameter type scope.
      if (!(await module.hasProviderScope(provider))) {
        throw Exception(
            'The provider ${parameter.type.reflectedType} must be declared in the module ${module.type}.');
      }

      final ModuleContext owner = await findProviderOwnerModule(provider);

      return await compileProvider(owner, provider);
    } else if (parameter.hasDefaultValue) {
      if (parameter.defaultValue != null) {
        return SingletonToken(Symbol.empty, parameter.defaultValue!.reflectee);
      }

      return null;
    }

    throw Exception('The parameter type ${parameter.type} is not supported.');
  }

  /// Find provider owner module.
  Future<ModuleContext> findProviderOwnerModule(Type provider) async {
    final Iterator<ParrotToken<ModuleContext>> iterator =
        container.whereType<ParrotToken<ModuleContext>>().iterator;

    while (iterator.moveNext()) {
      final ModuleContext module = await iterator.current.resolve();
      if (module.annotation.providers.contains(provider)) {
        return module;
      }
    }

    throw Exception('The provider $provider not found owner module.');
  }
}

class ResolvedArgument {
  const ResolvedArgument(this.mirror, this.token);

  final ParameterMirror mirror;

  final ParrotToken? token;
}
