import 'package:todo_list/app.dart';
import 'package:todo_list/module.dart';

import 'package:parrot/src/parrot_application.dart';

Future<void> main(List<String> arguments) async {
  var appContext = ParrotApplication.create(AppModule);
  var app = appContext.get<App>();

  await app.run();
}
