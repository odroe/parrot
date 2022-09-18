import 'package:shelf/shelf.dart';

/// A middleware that can be used to wrap a [ParrotMiddleware] and
/// add additional functionality.
///
/// Example:
/// ```dart
/// @Injectable()
/// class MyMiddleware extends ParrotMiddleware {
///   @override
///   Future<void> handle(Request request, MiddlewareNext next) {
///     // Do something with the request
///     return next(request);
///   }
/// }
///
/// @Controller(
///   middleware: [MyMiddleware],
/// )
/// class MyController {}
/// ```
abstract class ParrotMiddleware {
  const ParrotMiddleware();

  /// Handles the request and response.
  ///
  /// The [next] is the next middleware in the chain.
  Future<Response> handle(Request request, Handler next);
}
