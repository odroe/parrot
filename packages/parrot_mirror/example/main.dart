import 'package:parrot/parrot.dart';
import 'package:parrot_mirror/parrot_mirror.dart';

String hello() => 'Hello';

@Injectable(factory: ParrotService.hello)
class ParrotService {
  final String text;

  const ParrotService.hello(@Inject(hello) this.text);

  void say() {
    print('🦜 $text Parrot!');
  }
}

@Module(
  providers: {hello, ParrotService},
)
class AppModule {}

void main() async {
  final ParrotApplication app = ParrotApplication(AppModule);

  // Initialize application.
  await app.initialize(compiler);

  final ParrotService service = await app.find(ParrotService);

  service.say();
}
