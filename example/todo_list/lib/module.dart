import 'package:todo_list/app.dart';
import 'package:todo_list/todo_list.dart';

import 'package:parrot/parrot.dart';

@Module(
  exports: [
    App,
    TodoListService,
  ],
)
class AppModule {}
