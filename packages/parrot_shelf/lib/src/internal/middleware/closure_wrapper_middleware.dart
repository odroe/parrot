import 'package:parrot/parrot.dart';
import 'package:shelf/shelf.dart';

import '../../middleware/parrot_middleware.dart';
import '../../middleware/typed.dart';

class ClosureWrapperMiddleware implements ParrotMiddleware {
  const ClosureWrapperMiddleware(this.application, this.closure);

  final ParrotApplication application;
  final FunctionalMiddleware closure;

  @override
  Future<Response> handle(Request request, Handler next) async =>
      await closure(application, request, next);
}
