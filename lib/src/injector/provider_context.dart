import '../container/parrot_token.dart';
import '../utils/typed_symbol.dart';

abstract class ProviderContext<T> extends ParrotToken<T> {
  ProviderContext({
    required this.modules,
    required this.provider,
  }) : super(TypedSymbol.create(provider));

  /// Modules described by the current provider.
  final List<Type> modules;

  /// The provider type
  final Type provider;
}

/// Instance provider context.
class SingletonProviderContext<T> extends ProviderContext<T>
    implements SingletonToken<T> {
  SingletonProviderContext({
    required super.modules,
    required super.provider,
    required this.instance,
  });

  /// The provider instance.
  @override
  final T instance;

  @override
  Future<T> resolve() async => instance;
}

/// Transient provider context.
class TransientProviderContext<T> extends ProviderContext<T>
    implements TransientToken<T> {
  TransientProviderContext({
    required super.modules,
    required super.provider,
    required this.factory,
  });

  /// The provider value.
  @override
  final Future<T> Function() factory;

  @override
  Future<T> resolve() => factory();
}
