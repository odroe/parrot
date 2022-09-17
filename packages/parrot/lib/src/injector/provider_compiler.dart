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
        findFactoryMethodMirror(classMirror, factoryName);

    // Check circular dependencies.
    // Using [findProviderDependencyTree] to check circular dependencies.
    // Because the method of circular dependency will throw an error.
    findProviderDependencyTree(classMirror, factoryName);

    // Create the provider factory.
    Future<Object> factory() async => classMirror
        .newInstance(
          factoryMirror.constructorName,
          await resolvePositionalArguments(module, factoryMirror.parameters),
          await resilveNamedArguments(module, factoryMirror.parameters),
        )
        .reflectee;

    return TransientProviderContext(
      modules: await findProviderOwnerModules(classMirror),
      type: classMirror.reflectedType,
      factory: factory,
    );
  }

  /// Resolve positional arguments.
  Future<List> resolvePositionalArguments(
    ModuleContext module,
    List<ParameterMirror> parameters,
  ) async {
    final List<ParameterMirror> positionalParameters = parameters
        .where((ParameterMirror parameter) => !parameter.isNamed)
        .toList();
    final Iterator<ParameterMirror> iterator = positionalParameters.iterator;

    final List positionalArguments = [];
    while (iterator.moveNext()) {
      positionalArguments.add(await compileArgument(module, iterator.current));
    }

    return positionalArguments;
  }

  /// Resolve named arguments.
  Future<Map<Symbol, dynamic>> resilveNamedArguments(
    ModuleContext module,
    List<ParameterMirror> parameters,
  ) async {
    final List<ParameterMirror> namedParameters = parameters
        .where((ParameterMirror parameter) => parameter.isNamed)
        .toList();
    final Iterator<ParameterMirror> iterator = namedParameters.iterator;

    final Map<Symbol, dynamic> namedArguments = {};
    while (iterator.moveNext()) {
      namedArguments[iterator.current.simpleName] = await compileArgument(
        module,
        iterator.current,
      );
    }

    return namedArguments;
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

  /// Find the factory method mirror.
  MethodMirror findFactoryMethodMirror(
      ClassMirror classMirror, Symbol factoryName) {
    final Symbol symbol = factoryName == Symbol.empty
        ? Symbol(classMirror.reflectedType.toString())
        : factoryName;

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
      } else if (declarationMirror.isAbstract) {
        throw Exception('The provider factory $symbol must not be abstract.');
      } else if (declarationMirror.isPrivate) {
        throw Exception('The provider factory $symbol must not be private.');
      }

      throw Exception(
          'The factory method $symbol must be a constructor of the provider ${classMirror.reflectedType}.');
    }

    throw Exception(
        'The factory method $symbol does not exist in the class ${classMirror.reflectedType}.');
  }

  /// Compile argument.
  Future<dynamic> compileArgument(
    ModuleContext module,
    ParameterMirror parameter,
  ) async {
    if (parameter.type.reflectedType == null.runtimeType) {
      return null;
    } else if (hasInjectableAnnotation(parameter.type)) {
      // Check the parameter type scope.
      if (!(await module.hasProviderScope(parameter.type.reflectedType))) {
        throw Exception(
            'The provider ${parameter.type.reflectedType} must be declared in the module ${module.type}.');
      }

      final ProviderContext result =
          await compileProvider(module, parameter.type.reflectedType);

      return result.resolve();
    } else if (parameter.hasDefaultValue) {
      return parameter.defaultValue;
    }

    throw Exception('The parameter type ${parameter.type} is not supported.');
  }

  /// Has injectable annotation.
  bool hasInjectableAnnotation(TypeMirror mirror) {
    if (mirror is! ClassMirror) return false;

    return mirror.metadata.where((InstanceMirror annotation) {
      return annotation.reflectee is Injectable;
    }).isNotEmpty;
  }

  /// Find Provider Dependency Tree.
  ///
  /// If a circular dependency occurs, an error is thrown.
  ProviderDependencyTree findProviderDependencyTree(
      ClassMirror provider, Symbol factoryName,
      [ProviderDependencyTree? parent]) {
    ProviderDependencyTree? node = parent;
    while (node != null) {
      if (node.provider == provider.reflectedType) {
        throw Exception('''
Circular dependency detected:
    ${parent!.toDependencyPath(node.provider.toString())}

If your provider requires circular dependencies, use property-based injection：
    @Injectable()
    class A {
      @Inject() late final B b;
    }

    @Injectable()
    class B {
      @Inject() late final A a;
    }
''');
      }

      node = node.parent;
    }

    final ProviderDependencyTree dependencyTree =
        ProviderDependencyTree(provider.reflectedType, parent);

    // Find the factory method mirror.
    final MethodMirror factoryMirror =
        findFactoryMethodMirror(provider, factoryName);

    // Get parameters iterator.
    final Iterator<ParameterMirror> iterator =
        factoryMirror.parameters.iterator;

    while (iterator.moveNext()) {
      final ParameterMirror parameter = iterator.current;

      if (parameter.type is ClassMirror) {
        dependencyTree.dependencies.add(findProviderDependencyTree(
          parameter.type as ClassMirror,
          resolveProviderFactoryName(parameter.type as ClassMirror),
          dependencyTree,
        ));
        continue;
      }

      dependencyTree.dependencies.add(ProviderDependencyTree(
        parameter.type.reflectedType,
        dependencyTree,
      ));
    }

    return dependencyTree;
  }

  /// Resolve factory name.
  Symbol resolveProviderFactoryName(ClassMirror classMirror) {
    final Iterable<Injectable> results = classMirror.metadata
        .map((InstanceMirror element) => element.reflectee)
        .whereType<Injectable>();

    if (results.length != 1) {
      throw Exception(
          'The provider ${classMirror.reflectedType} must have exactly one `@Injectable()` annotation.');
    }

    return results.first.factory;
  }
}

class ProviderDependencyTree {
  ProviderDependencyTree(this.provider, [this.parent]);

  final ProviderDependencyTree? parent;
  final Type provider;
  final List<ProviderDependencyTree> dependencies = [];

  // Returns dependency path.
  String toDependencyPath([String? end]) {
    final List<String> path = [];
    if (end != null) path.add(end);

    ProviderDependencyTree? dependency = this;
    while (dependency != null) {
      path.add(dependency.provider.toString());
      dependency = dependency.parent;
    }

    return path.reversed.join(' -> ');
  }
}
