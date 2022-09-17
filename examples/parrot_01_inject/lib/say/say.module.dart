import 'package:parrot/parrot.dart';

import 'say.service.dart';

@Module(
  providers: [SayService],
  exports: [SayService],
)
class SayModule {}
