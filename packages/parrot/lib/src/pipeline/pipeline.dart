import 'handler.dart';
import 'middleware.dart';

/// A helper that makes it easy to compose a set of [Middleware]
/// and a [Handler].
///
/// ```dart
/// final pipeline = Pipeline<int, int>()
///  .addMiddleware((handler) => (value) {
///      print('before');
///    return handler(value).then((result) {
///      print('after');
///     return result;
///     });
///  });
/// final handler = pipeline((value) async => value + 1);
///
/// handler(1).then((result) => print(result)); // prints 'before', 'after', '2'
/// ```
class Pipeline<T, R> {
  const Pipeline();

  /// Adds a [Middleware] to the pipeline.
  Pipeline<T, R> addMiddleware(Middleware<T, R> middleware) =>
      _PipelineInternal<T, R>(middleware, this);

  /// Calls a [Handler] with the pipeline.
  ///
  /// Returns a [Handler] that will execute the pipeline.
  Handler<T, R> call(Handler<T, R> handler) => handler;
}

class _PipelineInternal<T, R> extends Pipeline<T, R> {
  const _PipelineInternal(this.middleware, this.parent);

  final Middleware<T, R> middleware;
  final Middleware<T, R> parent;

  @override
  Handler<T, R> call(Handler<T, R> handler) => parent(middleware(handler));
}
