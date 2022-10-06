/// Parrot mirror.
library parrot.mirror;

import 'package:parrot/parrot.dart';

Future<void> withMirrorSystem(ParrotApplication app) async {
  if (app is! ApplicationInitiator) {
    throw UnimplementedError(
        'The application is not implement [ApplicationInitiator]');
  }
}
