import '../provider_context.dart';

abstract class SingletonProviderContext<T> extends ProviderContext<T> {
  const SingletonProviderContext({
    required super.module,
    required this.instance,
    super.scope,
  });

  /// The singleton instance.
  final T instance;
}
