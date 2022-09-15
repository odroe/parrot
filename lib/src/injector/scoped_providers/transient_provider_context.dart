import 'dart:async';

import '../provider_context.dart';
import '../provider_creator.dart';

class TransientProviderContext<T> extends ProviderContext<ProviderCreator<T>> {
  const TransientProviderContext({
    required super.modules,
    required super.type,
    required super.value,
  });
}
