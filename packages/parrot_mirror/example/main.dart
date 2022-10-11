import 'package:parrot/parrot.dart';
import 'package:parrot_mirror/parrot_mirror.dart';

class HelloService {
  String get word => 'Hello';
}

@Injectable(factory: ParrotService.hello)
class ParrotService {
  final HelloService hello;

  const ParrotService.hello(this.hello);
}

@Module(
  providers: {
    HelloService,
    ParrotService,
  },
)
class AppModule {}

void main() async {
  final ParrotApplication app = ParrotApplication(AppModule);

  // Initialize application.
  await app.initialize(compiler);

  final ParrotService service = await app.find(ParrotService);

  print(service.hello.word);
}
