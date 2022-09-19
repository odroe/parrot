class Controller {
  const Controller({
    this.path,
    this.middleware = const [],
  });

  final String? path;
  final List<Type> middleware;
}
