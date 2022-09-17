import 'package:parrot/parrot.dart';

import 'say/say.interface.dart';
import 'say/say.service.dart';

@Injectable()
class AppService {
  const AppService(@Inject(SayService) this.sayService);

  final SayInterface sayService;

  void print() => sayService.say('🦜 Parrot');
}
