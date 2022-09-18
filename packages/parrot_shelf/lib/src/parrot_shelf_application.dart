import 'package:parrot/parrot.dart';

import 'middleware/middleware_configure.dart';
import 'middleware/parrot_middleware.dart';

extension ParrotShelfApplication on ParrotApplication {
  /// Add global middleware to the Parrot shelf application.
  ///
  /// Middleware is executed in the order it is added.
  ///
  /// ## Injectable class middleware:
  /// ```dart
  /// @Injectable()
  /// class LoggingMiddleware extends ParrotMiddleware {
  ///   @override
  ///   Future<void> handle(Request request, Handler next) {
  ///     // Do something with the request
  ///     return next(request);
  ///   }
  /// }
  ///
  /// @Module(
  ///   providers: [LoggingMiddleware],
  /// )
  /// class AppModule {}
  ///
  /// final app = await ParrotApplication.create(AppModule);
  ///
  /// // Add a middleware that logs the request
  /// app.use(LoggingMiddleware);
  /// ```
  ///
  /// ## Instance middleware:
  /// ```dart
  /// final app = await ParrotApplication.create(AppModule);
  /// final loggingMiddleware = LoggingMiddleware();
  /// app.use(loggingMiddleware);
  /// ```
  ///
  /// ## Functional middleware:
  /// ```dart
  /// final app = await ParrotApplication.create(AppModule);
  /// app.use((request, next) {
  ///   // Do something with the request
  ///   return next(request);
  /// });
  /// ```
  ///
  /// ## See also:
  /// * [ParrotMiddleware]
  /// * [MiddlewareConfigure]
  MiddlewareConfigure use(Object middleware) {
    throw UnimplementedError();
  }
}
