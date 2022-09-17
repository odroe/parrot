import 'handler.dart';

/// A function which creates a new [Handler] by wrapping a [Handler].
typedef Middleware<T, R> = Handler<T, R> Function(Handler<T, R>);
