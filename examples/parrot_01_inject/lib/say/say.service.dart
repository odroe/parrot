import 'package:parrot/parrot.dart';

import 'say.interface.dart';

@Injectable()
class SayService implements SayInterface {
  @override
  void say(String name) {
    print('Hello, $name!');
  }
}
