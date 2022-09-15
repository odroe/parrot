import '../provider_context.dart';

class SingletonProviderContext<T extends Object> extends ProviderContext<T> {
  const SingletonProviderContext({
    required super.modules,
    required super.type,
    required super.value,
  });
}
