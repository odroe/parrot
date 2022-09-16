import '../container/parrot_token.dart';
import '../utils/typed_symbol.dart';

abstract class ProviderContext<T extends Object> extends ParrotToken<T> {
  ProviderContext({
    required this.modules,
    required this.type,
  }) : super(TypedSymbol.create(type));

  /// Modules described by the current provider.
  final List<Type> modules;

  /// The provider type
  @override
  final Type type;
}

/// Instance provider context.
class SingletonProviderContext<T extends Object> extends ProviderContext<T>
    implements SingletonToken<T> {
  SingletonProviderContext({
    required super.modules,
    required super.type,
    required this.instance,
  });

  /// The provider instance.
  @override
  final T instance;

  @override
  Future<T> resolve() async => instance;
}

/// Transient provider context.
class TransientProviderContext<T extends Object> extends ProviderContext<T>
    implements TransientToken<T> {
  TransientProviderContext({
    required super.modules,
    required super.type,
    required this.factory,
  });

  /// The provider value.
  @override
  final Future<T> Function() factory;

  @override
  Future<T> resolve() => factory();
}
