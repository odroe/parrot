import 'dart:mirrors';
import 'package:parrot/parrot.dart';

import 'compiler.dart';

mixin ProviderCompiler on Compiler {
  @override
  Future<InstanceContext<T>> compileProvider<T>(
      Object provider, ModuleContext context) async {
    final Provider resolvedProvider = _resolveProvider(provider);

    // Class provider.
    if (resolvedProvider is ClassProvider) {
      return compileClassProvider<T>(resolvedProvider, context);

      // Factory provider.
    } else if (resolvedProvider is FactoryProvider<T>) {
      return compileFactoryProvider<T>(resolvedProvider, context);

      // Value provider.
    } else if (resolvedProvider is ValueProvider<T>) {
      return compileValueProvider<T>(resolvedProvider, context);
    }

    return compileExistingProvider<T>(
        resolvedProvider as ExistingProvider, context);
  }

  /// Resolve provider.
  Provider _resolveProvider(Object provider) {
    // provider is a [Provider], return it.
    if (provider is Provider) {
      return provider;

      // If the provider is a [Type], create a [ClassProvider].
    } else if (provider is Type) {
      return ClassProvider(useClass: provider, token: provider);

      // If the provider is a [FactoryProviderFunction], Create a
      // [FactoryProvider].
    } else if (provider is Function) {
      return FactoryProvider(token: provider, useFactory: provider);
    }

    throw ArgumentError.value(provider, 'provider', 'Invalid provider.');
  }
}

/// Constructor parameters resolver.
extension on ProviderCompiler {
  /// Resolve constructor parameters.
  Future<Map<ParameterMirror, InstanceContext>> resolveConstructorParameters({
    required Iterable<ParameterMirror> parameters,
    required ModuleContext context,
  }) async {
    final Map<ParameterMirror, InstanceContext> resolvedParameters = {};

    for (final ParameterMirror parameter in parameters) {
      InstanceContext? instanceContext = await createParameterContext(
        parameter: parameter,
        context: context,
      );

      // If instance context is null
      if (instanceContext == null) {
        instanceContext = InstanceContext(
          token: parameter,
          factory: () async => parameter.defaultValue?.reflectee,
        );

        if (!parameter.isOptional && !parameter.hasDefaultValue) {
          throw ArgumentError.value(
            parameter,
            'parameter',
            'Parameter no injectable provider was found and the parameter is not optional or has not a default value.',
          );
        }
      }

      resolvedParameters[parameter] = instanceContext;
    }

    return resolvedParameters;
  }

  /// Create parameter context.
  Future<InstanceContext?> createParameterContext({
    required ParameterMirror parameter,
    required ModuleContext context,
  }) async {
    final Object token = resolveParameterToken(parameter);

    // If the token is current module context instance, return the module.
    if (token == context.token) {
      return context;
    }

    // If the token is the provider of the current module.
    if (context.metadata.providers.any((element) =>
        element == token || (element is Provider && element.token == token))) {
      // Create token provider.
      final Object provider =
          context.metadata.providers.reduce((value, element) {
        if (element == token ||
            (element is Provider && element.token == token)) {
          return element;
        }

        return value;
      });

      return compileProvider(provider, context);
    }

    // Compile dependency module and has exported.
    for (final Object dependency in context.metadata.dependencies) {
      final ModuleContext dependencyModuleContext =
          await compileModule(dependency, context);
      final InstanceContext? instanceContext = await createParameterContext(
        parameter: parameter,
        context: dependencyModuleContext,
      );

      if (instanceContext != null) {
        return instanceContext;
      }
    }

    return null;
  }

  /// Resolve parameter token.
  Object resolveParameterToken(ParameterMirror parameter) {
    final Inject? inject = findInjectAnnotation(parameter.metadata);

    return inject?.token ?? parameter.type.reflectedType;
  }

  /// Find `@Inject` annotation.
  Inject? findInjectAnnotation(Iterable<InstanceMirror> metadata) {
    final Iterable<Inject> injectAnnotations = metadata
        .whereType<InstanceMirror>()
        .map((e) => e.reflectee)
        .whereType<Inject>();

    if (injectAnnotations.length > 1) {
      throw ArgumentError.value(injectAnnotations, 'metadata',
          'Parameter must be annotated with a single [Inject] annotation.');
    }

    return injectAnnotations.isEmpty ? null : injectAnnotations.single;
  }
}

/// Existing provider compiler.
extension on ProviderCompiler {
  /// Compile existing provider.
  Future<InstanceContext<T>> compileExistingProvider<T>(
      ExistingProvider provider, ModuleContext context) async {
    final InstanceContext<T> instanceContext =
        await compileProvider<T>(provider.useExisting, context);
    instanceContext.addAlias(provider.token);

    return instanceContext;
  }
}

/// Value provider compiler.
extension on ProviderCompiler {
  /// Compile value provider.
  InstanceContext<T> compileValueProvider<T>(
      ValueProvider<T> provider, ModuleContext ref) {
    if (container.has(provider.token)) {
      return container.getInstanceContext(provider.token);
    }

    final InstanceContext<T> instanceContext = InstanceContext<T>(
      token: provider.token,
      factory: () async => provider.useValue,
    );

    // Add instance context to container.
    container.addInstanceContext(instanceContext);

    return instanceContext;
  }
}

/// Factory provider compiler.
extension on ProviderCompiler {
  /// Compile factory provider.
  Future<InstanceContext<T>> compileFactoryProvider<T>(
      FactoryProvider<T> provider, ModuleContext moduleContext) async {
    if (container.has(provider.token)) {
      return container.getInstanceContext<T>(provider.token);
    }

    return createFactoryInstanceContext(
      token: provider.token,
      context: moduleContext,
      closureMirror: reflect(provider.useFactory) as ClosureMirror,
    );
  }

  /// Create a instance context with factory.
  Future<InstanceContext<T>> createFactoryInstanceContext<T>({
    required Object token,
    required ModuleContext context,
    required ClosureMirror closureMirror,
  }) async {
    final Map<ParameterMirror, InstanceContext> parameters =
        await resolveConstructorParameters(
      parameters: closureMirror.function.parameters,
      context: context,
    );
    final Iterable<InstanceContext> positionalParameters = parameters.entries
        .where((e) => e.key.isNamed == false)
        .map((e) => e.value);
    final Map<Symbol, InstanceContext> namedParameters = Map.fromEntries(
      parameters.entries
          .where((e) => e.key.isNamed)
          .map((e) => MapEntry(e.key.simpleName, e.value)),
    );
    final InstanceContext<T> factoryContext = InstanceContext<T>(
      token: token,
      factory: () async {
        // Resolve positional parameters values.
        final List positionalParametersValues = await Future.wait(
          positionalParameters.map((e) => container.getInstance(e.token)),
        );

        // Resolve named parameters values.
        final Map<Symbol, Object> namedParametersValues = Map.fromEntries(
          await Future.wait(
            namedParameters.entries.map((e) async {
              final Object value = await container.getInstance(e.value.token);

              return MapEntry(e.key, value);
            }),
          ),
        );

        return closureMirror
            .apply(positionalParametersValues, namedParametersValues)
            .reflectee;
      },
    );

    // Add factory context to container.
    container.addInstanceContext(factoryContext);

    return factoryContext;
  }
}

/// Compile a [ClassProvider].
extension on ProviderCompiler {
  /// Compile a [ClassProvider].
  Future<InstanceContext<T>> compileClassProvider<T>(
      ClassProvider provider, ModuleContext context) async {
    // If the provider token is registered, return it.
    if (container.has(provider.token)) {
      return container.getInstanceContext<T>(provider.token);
    }

    final ClassMirror classMirror = reflectClass(provider.useClass);
    final Mirror factoryMirror = findClassFactoryMethod(classMirror);

    // If the factory mirror is a [MethodMirror].
    if (factoryMirror is MethodMirror) {
      return createClassInstanceContext<T>(
        token: provider.token,
        context: context,
        methodMirror: factoryMirror,
        classMirror: classMirror,
      );
    }

    return createFactoryInstanceContext<T>(
      token: provider.token,
      context: context,
      closureMirror: factoryMirror as ClosureMirror,
    );
  }

  /// Create a class instance context with new instance.
  Future<InstanceContext<T>> createClassInstanceContext<T>({
    required Object token,
    required ModuleContext context,
    required MethodMirror methodMirror,
    required ClassMirror classMirror,
  }) async {
    final Map<ParameterMirror, InstanceContext> parameters =
        await resolveConstructorParameters(
      parameters: methodMirror.parameters,
      context: context,
    );
    final Iterable<InstanceContext> positionalParameters = parameters.entries
        .where((e) => e.key.isNamed == false)
        .map((e) => e.value);
    final Map<Symbol, InstanceContext> namedParameters = Map.fromEntries(
      parameters.entries
          .where((e) => e.key.isNamed)
          .map((e) => MapEntry(e.key.simpleName, e.value)),
    );

    final InstanceContext<T> instanceContext = InstanceContext(
      token: token,
      factory: () async {
        // Resolve positional parameters values.
        final List positionalParametersValues = await Future.wait(
          positionalParameters.map((e) => container.getInstance(e.token)),
        );

        // Resolve named parameters values.
        final Map<Symbol, Object> namedParametersValues = Map.fromEntries(
          await Future.wait(
            namedParameters.entries.map((e) async {
              final Object value = await container.getInstance(e.value.token);

              return MapEntry(e.key, value);
            }),
          ),
        );

        /// Create instance mirror.
        final InstanceMirror instanceMirror = classMirror.newInstance(
          methodMirror.constructorName,
          positionalParametersValues,
          namedParametersValues,
        );

        return instanceMirror.reflectee;
      },
    );

    // Add instance context to container.
    container.addInstanceContext<T>(instanceContext);

    return instanceContext;
  }

  /// Find class factory method.
  Mirror findClassFactoryMethod(ClassMirror classMirror) {
    final Injectable injectable = findClassInjectableAnnotation(classMirror);

    if (injectable.factory != null) {
      final InstanceMirror instanceMirror = reflect(injectable.factory);

      if (instanceMirror is ClosureMirror &&
          instanceMirror.function.returnType == classMirror) {
        return instanceMirror;
      }

      throw ArgumentError.value(injectable.factory, 'factory',
          'The factory method must return the [${classMirror.reflectedType}].');
    }

    // Create a factory method name.
    final DeclarationMirror? declarationMirror = classMirror
            .declarations[classMirror.simpleName] ??
        classMirror.declarations[Symbol(classMirror.reflectedType.toString())];

    // If declaration mirror is a [MethodMirror], return it.
    if (declarationMirror is MethodMirror &&
        declarationMirror.returnType == classMirror) {
      return declarationMirror;
    }

    throw Exception(
        'Cannot find default factory/constructor method for ${classMirror.reflectedType}');
  }

  /// Find class injectable annotation.
  Injectable findClassInjectableAnnotation(ClassMirror classMirror) {
    final Iterable<Injectable> injectableAnnotations = classMirror.metadata
        .whereType<InstanceMirror>()
        .map((e) => e.reflectee)
        .whereType<Injectable>();

    if (injectableAnnotations.length > 1) {
      throw ArgumentError.value(classMirror, 'classMirror',
          'Only one injectable annotation allowed.');
    }

    return injectableAnnotations.isNotEmpty
        ? injectableAnnotations.single
        : const Injectable();
  }
}
