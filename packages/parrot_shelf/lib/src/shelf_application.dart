import 'dart:io';

import 'package:parrot/parrot.dart';
import 'package:shelf/shelf_io.dart';

import 'router/router_builder.dart';
import 'utils/get_free_port.dart';

extension ShelfApplication on ParrotApplication {
  /// Listens for HTTP requests on the specified [address] and [port].
  ///
  /// If [address] is `null`, this will listen on all available IPv4 addresses
  /// (not IPv6 addresses).
  ///
  /// If [port] is `null`, this will listen on a random port.
  Future<HttpServer> listen({
    int? port,
    Object? address,
    SecurityContext? securityContext,
    int? backlog,
    bool shared = false,
  }) async =>
      serve(
        await RouterBuilder.single(this),
        address ?? InternetAddress.anyIPv4,
        port ?? await getFreePort(),
        securityContext: securityContext,
        backlog: backlog,
        shared: shared,
      );
}
