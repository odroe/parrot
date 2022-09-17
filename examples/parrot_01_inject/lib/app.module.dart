import 'package:parrot/parrot.dart';

import 'app.service.dart';
import 'say/say.module.dart';

@Module(
  dependencies: [SayModule],
  providers: [AppService],
)
class AppModule {}
