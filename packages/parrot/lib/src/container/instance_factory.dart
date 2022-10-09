import 'parrot_container.dart';

/// Instance factory.
typedef InstanceFactory<T> = Future<T> Function(ParrotContainer container);
