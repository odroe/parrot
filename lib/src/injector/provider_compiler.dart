import 'dart:mirrors';

import 'package:parrot/src/injector/module_context.dart';

import '../annotations/injectable.dart';
import '../container/parrot_container.dart';
import '../container/parrot_token.dart';
import '../utils/typed_symbol.dart';
import 'provider_context.dart';
import 'scope.dart';

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
        provider: context.provider,
        instance: await context.resolve(),
      );
    }

    return context;
  }

  /// Create a [TransientProviderContext].
  Future<TransientProviderContext> createTransientProviderContext(
    ModuleContext module,
    ClassMirror classMirror,
    Symbol factory,
  ) async {
    final MethodMirror factoryMirror =
        findFactoryMethodMirror(classMirror, factory);

    print(factoryMirror.parameters.first.type);

    // classMirror.newInstance(factoryMirror.constructorName, positionalArguments)
    throw UnimplementedError();
  }

  /// Find the factory method mirror.
  MethodMirror findFactoryMethodMirror(
      ClassMirror classMirror, Symbol factory) {
    final Symbol symbol = factory == Symbol.empty
        ? Symbol(classMirror.reflectedType.toString())
        : factory;

    final DeclarationMirror? declarationMirror =
        classMirror.declarations[symbol];
    if (declarationMirror != null && declarationMirror is MethodMirror) {
      // If the factory not is a constructor, throw an error.
      if (declarationMirror.isConstConstructor ||
          declarationMirror.isConstructor ||
          declarationMirror.isFactoryConstructor ||
          declarationMirror.isGenerativeConstructor ||
          declarationMirror.isRedirectingConstructor) {
        return declarationMirror;
      }

      throw Exception(
          'The factory method $symbol must be a constructor of the provider ${classMirror.reflectedType}.');
    }

    throw Exception(
        'The factory method $symbol does not exist in the class ${classMirror.reflectedType}.');
  }
}
