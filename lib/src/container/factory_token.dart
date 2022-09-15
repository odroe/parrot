import 'dart:async';

import 'parrot_token.dart';

/// Factory token instance creator.
typedef InstanceFactory<T> = FutureOr<T> Function();

/// Factory token.
class FactoryToken<T> extends ParrotToken<InstanceFactory<T>> {
  FactoryToken(super.key, super.value);

  /// Cache the instance.
  T? _instance;

  /// Resolve the instance.
  ///
  /// If instance is not null, return the instance.
  /// Otherwise, create a new instance and return it.
  FutureOr<T> resolve() async => _instance ??= await value();
}
