import '../provider_context.dart';
import '../provider_creator.dart';

abstract class TransientProviderContext<T> extends ProviderContext<T> {
  const TransientProviderContext({
    required this.creator,
    required super.module,
    super.scope,
  });

  /// The provider instance creator.
  final ProviderCreator creator;
}
