import 'package:parrot/parrot.dart';

class ShelfModule extends Module {
  const ShelfModule({
    this.controllers = const [],
    super.dependencies,
    super.exports,
    super.global,
    super.providers,
  });

  final Iterable<Type> controllers;
}
