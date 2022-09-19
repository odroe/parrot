import 'package:parrot/parrot.dart';
import 'package:shelf_router/shelf_router.dart';

class RouterBuilder {
  RouterBuilder._(this.app);

  static Future<Router>? _router;

  static Future<Router> single(ParrotApplication app) =>
      _router ??= RouterBuilder._(app).build();

  final ParrotApplication app;

  /// Build a [Router] from the [ParrotApplication].
  Future<Router> build() {
    throw UnimplementedError();
  }
}
