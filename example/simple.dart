import 'package:parrot/parrot.dart';

@Module()
class UserModule {}

@Injectable()
class SimpleService {
  void say() {
    print('Hello, 🦜 Parrot!');
  }
}

@Module(
  dependencies: [UserModule],
  providers: [SimpleService],
)
class SimpleModule {}

@Module(
  dependencies: [SimpleModule],
)
class AppModule {}

void main() {
  final app = ParrotApplication(AppModule);

  print(app.select(UserModule).module);
  // final SimpleService service = app.resolve(SimpleService);

  // service.say(); // Hello, 🦜 Parrot!
}
