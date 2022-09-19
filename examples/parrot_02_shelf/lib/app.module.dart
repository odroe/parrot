import 'package:parrot_shelf/parrot_shelf.dart';

import 'app.controller.dart';
import 'app.service.dart';

@ShelfModule(
  controllers: [AppController],
  providers: [AppService],
)
class AppModule {}
