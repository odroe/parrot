import 'dart:mirrors';

import 'package:parrot/src/container/v1/internal/helpers/interpreter.dart';

import 'mirror.dart';

class InstanceSpec {
  const InstanceSpec({
    required this.id,
    required this.name,
    required this.lifetime,
    required this.provider,
    required this.scopes,
    required this.compatibleTypes,
  });

  final int id;

  final String name;

  final InstanceLifetime lifetime;

  final InstanceProvider provider;

  final List<String> scopes;

  final List<Type> compatibleTypes;

  Type get objectType => provider.objectType;

  Iterable<BuildStep> get buildSteps => provider.buildSteps;

  bool isCompatibleWithType(Type type) {
    return [...compatibleTypes, objectType].contains(type);
  }
}

enum InstanceLifetime {
  singleton,
  transient,
}

abstract class InstanceRequest {
  bool matchInstanceSpec(InstanceSpec spec);

  bool matchInstance(Instance instance);
}

abstract class InstanceProvider<T> {
  static InstanceProvider reflectClass<T>() => _ReflectClassProvider<T>();

  static InstanceProvider value<T>(T value) => _ValueProvider<T>(value);

  static InstanceProvider factory<T>({
    required Map<Object, InstanceRequest> dependencies,
    required Object Function(Map<Object, Instance>) constructor,
  }) =>
      _FactoryProvider<T>(dependencies, constructor);

  Type get objectType;

  Iterable<BuildStep> get buildSteps;
}

class Instance {
  const Instance({
    required this.id,
    required this.spec,
    required this.scope,
    required this.lifetime,
    required this.type,
    required this.object,
  });

  final int id;

  final InstanceSpec spec;

  final String scope;

  final InstanceLifetime lifetime;

  final Type type;

  final Object object;

  InstanceReference get reference => InstanceReference(this);

  bool matchType(Type type) {
    return type == this.type;
  }
}

class InstanceReference {
  InstanceReference(this.instance);

  final Instance instance;
}

abstract class BuildStep implements Instruction {}

class EmittedInstruction extends Marker {
  const EmittedInstruction(this.instruction, {this.parent});

  final Instruction instruction;

  @override
  final Context? parent;
}

class _MatchExactType implements InstanceRequest {
  const _MatchExactType(this.type);

  final Type type;

  @override
  bool matchInstanceSpec(InstanceSpec spec) {
    return spec.isCompatibleWithType(type);
  }

  @override
  bool matchInstance(Instance instance) {
    return instance.matchType(type);
  }
}

class _ReflectClassProvider<T> implements InstanceProvider<T> {
  _ReflectClassProvider();

  Type get classType => T;

  late ClassMirror clazz = reflectClass(classType);

  late MethodMirror constructor = findConstructors(clazz).first;

  late List<ParameterMirror> constructorParams = constructor.parameters;

  late List<VariableMirror> lazyInject =
      clazz.declarations.values.whereType<VariableMirror>().toList();

  @override
  Type get objectType => classType;

  @override
  late Iterable<BuildStep> buildSteps = [
    ConstructObject(
      type: classType,
      dependencies: Map.fromEntries(
        constructorParams
            .where((e) => !e.isOptional)
            .map((e) => MapEntry(e, _MatchExactType(e.type.reflectedType))),
      ),
      constructor: (dependencies) => clazz.newInstance(
        constructor.constructorName,
        constructorParams
            .where((e) => !e.isNamed && !e.isOptional)
            .map((e) => dependencies[e])
            .toList(),
        Map.fromEntries(constructorParams
            .where((e) => e.isNamed && !e.isOptional)
            .map((e) => MapEntry(e.simpleName, dependencies[e]))),
      ),
    ),
    ...lazyInject.map((mirror) => ConfigureObject())
  ];
}

class _ValueProvider<T> implements InstanceProvider {
  _ValueProvider(this.value);

  Type get type => T;

  final T value;

  @override
  Type get objectType => type;

  @override
  late Iterable<BuildStep> buildSteps = [
    ProvideObject(
      type: objectType,
      object: value as Object,
    ),
  ];
}

class _FactoryProvider<T> implements InstanceProvider {
  _FactoryProvider(
    this.dependencies,
    this.constructor,
  );

  final Map<Object, InstanceRequest> dependencies;

  Type get type => T;

  final Object Function(Map<Object, Instance> dependencies) constructor;

  @override
  Type get objectType => type;

  @override
  late Iterable<BuildStep> buildSteps = [
    ConstructObject(
      type: type,
      dependencies: dependencies,
      constructor: constructor,
    )
  ];
}

class ProvideObject implements BuildStep {
  const ProvideObject({required this.type, required this.object});

  final Type type;

  final Object object;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    final instanceSpec = context
        .whereType<KeyedValue>()
        .where((e) => e.key == 0) as InstanceSpec;
    return Tuple2(
      context.mutable
          .apply((parent) => InstructionMarker(this, parent: parent))
          .apply((parent) => EmittedInstruction(ProvideInstance(
                instance: Instance(
                  id: id,
                  spec: spec,
                  scope: scope,
                  lifetime: lifetime,
                  type: type,
                  object: object,
                ),
              ))),
      None(),
    );
  }
}

class ConstructObject implements BuildStep {
  const ConstructObject({
    required this.type,
    required this.dependencies,
    required this.constructor,
  });

  final Type type;

  final Map<Object, InstanceRequest> dependencies;

  final Object Function(Map<Object, Instance> dependencies) constructor;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    final resolvedDependencies = dependencies.entries.map();
    return Tuple2(
      context,
      Some(ProvideObject(type: type, object: constructor())),
    );
  }

  @override
  String toString() {
    return "ConstructObject(type=${type.toString()})";
  }
}

class ConfigureObject<T> implements BuildStep {
  const ConfigureObject();

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    throw UnimplementedError();
  }

  @override
  String toString() {
    return "ConfigureObject<${T.toString()}>()";
  }
}

class LookupInstance implements Instruction {
  const LookupInstance(this.key, this.request);

  final Object key;

  final InstanceRequest request;

  @override
  Tuple2<Context, Option<Instruction>> run(
      Context context, InstructionTracer tracer) {
    return Tuple2(
      context.mutable
          .apply((parent) => InstructionMarker(this, parent: parent)),
      None(),
    );
  }
}

class ProvideInstance implements Instruction {
  const ProvideInstance({required this.instance});

  final Instance instance;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    return Tuple2(
      context.mutable
          .apply((parent) => InstructionMarker(this, parent: parent)),
      None(),
    );
  }
}
