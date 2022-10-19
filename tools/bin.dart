import 'package:parrot/parrot.dart';
import 'package:parrot_cmd/parrot_cmd.dart';

import 'src/app_module.dart';

void main(List<String> args) {
  final app = Parrot(appModule);

  app.run(args);
}
