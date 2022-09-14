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

void main() {
  final app = ParrotApplication(SimpleModule);
  final SimpleService service = app.resolve(SimpleService);

  service.say(); // Hello, 🦜 Parrot!
}
