import 'dart:async';

typedef ProviderCreator<T> = FutureOr<T> Function();
