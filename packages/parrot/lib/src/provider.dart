import 'module_ref.dart';

/// Basic provider.
abstract class Provider {
  Provider({required this.token});

  /// Provider token.
  final Object token;
}

/// Class provider.
class ClassProvider extends Provider {
  ClassProvider({
    required super.token,
    required this.useClass,
  });

  /// Class type.
  final Type useClass;
}

/// Factory provider.
class FactoryProvider<T> extends Provider {
  FactoryProvider({
    required super.token,
    required this.useFactory,
  });

  /// Provider instance create factory.
  final Function useFactory;
}

/// Value provider.
class ValueProvider<T> extends Provider {
  ValueProvider({
    required super.token,
    required this.useValue,
  });

  /// Provider instance.
  final T useValue;
}

/// Existing provider.
class ExistingProvider extends Provider {
  ExistingProvider({
    required super.token,
    required this.useExisting,
  });

  /// Existing provider token.
  final Object useExisting;
}
