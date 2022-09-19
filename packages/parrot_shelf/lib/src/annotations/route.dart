class Route {
  const Route(
    this.method, {
    this.path,
    this.middleware = const [],
  });

  final String method;

  final String? path;

  final List<Type> middleware;
}

class Get extends Route {
  const Get({
    String? path,
    List<Type> middleware = const [],
  }) : super('GET', path: path, middleware: middleware);
}

class Head extends Route {
  const Head({
    String? path,
    List<Type> middleware = const [],
  }) : super('HEAD', path: path, middleware: middleware);
}

class Post extends Route {
  const Post({
    String? path,
    List<Type> middleware = const [],
  }) : super('POST', path: path, middleware: middleware);
}

class Put extends Route {
  const Put({
    String? path,
    List<Type> middleware = const [],
  }) : super('PUT', path: path, middleware: middleware);
}

class Delete extends Route {
  const Delete({
    String? path,
    List<Type> middleware = const [],
  }) : super('DELETE', path: path, middleware: middleware);
}

class Connect extends Route {
  const Connect({
    String? path,
    List<Type> middleware = const [],
  }) : super('CONNECT', path: path, middleware: middleware);
}

class Options extends Route {
  const Options({
    String? path,
    List<Type> middleware = const [],
  }) : super('OPTIONS', path: path, middleware: middleware);
}

class Trace extends Route {
  const Trace({
    String? path,
    List<Type> middleware = const [],
  }) : super('TRACE', path: path, middleware: middleware);
}
