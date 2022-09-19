import 'dart:io';

/// returns free port.
Future<int> getFreePort() async {
  final ServerSocket socket =
      await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final int port = socket.port;
  await socket.close();

  return port;
}
