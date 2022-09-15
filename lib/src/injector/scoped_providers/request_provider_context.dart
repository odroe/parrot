import 'transient_provider_context.dart';

class RequestProviderContext<T> extends TransientProviderContext<T> {
  const RequestProviderContext({
    required super.modules,
    required super.type,
    required super.value,
  });
}
