import 'package:parrot/parrot.dart';

@Injectable()
class SimpleService {
  void say() {
    print('Hello, 🦜 Parrot!');
  }
}

@Module(
  providers: [SimpleService],
)
class SimpleModule {}

void main() async {
  // Create a parrot application.
  final ParrotApplication app = await ParrotApplication.create(SimpleModule);

  // Resolve [SimpleService] from the application.
  final SimpleService simple = await app.resolve(SimpleService);

  // Call say method.
  simple.say(); // Hello, 🦜 Parrot!
}
