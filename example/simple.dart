import 'package:parrot/parrot.dart';

@Injectable()
class SimpleService {
  void say() {
    print('Hello, 🦜 Parrot!');
  }
}

@Module(
  dependencies: [AppModule],
  providers: [SimpleService],
)
class SimpleModule {}

@Module(
  dependencies: [SimpleModule],
)
class AppModule {}

void main() async {
  final app = await ParrotApplication.create(AppModule);
  final module = await app.select(SimpleModule);
  final service = await module.get<SimpleService>(SimpleService);

  service.say(); // Hello, 🦜 Parrot!
}
