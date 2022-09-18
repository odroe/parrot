import 'dart:async';

import 'package:parrot/parrot.dart';
import 'package:shelf/shelf.dart';

/// Parrot shelf functional middleware.
///
/// Example:
/// ```dart
/// final app = await ParrotApplication.create(AppModule);
/// app.use((app, request, next) {
///   // Do something with the request
///   return next(request);
/// });
/// ```
typedef FunctionalMiddleware = FutureOr<Response> Function(
    ParrotApplication app, Request request, Handler next);
