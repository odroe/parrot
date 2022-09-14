import 'transient_provider_context.dart';

abstract class RequestProviderContext<T> extends TransientProviderContext<T> {
  const RequestProviderContext({
    required super.creator,
    required super.module,
    super.scope,
  });
}
