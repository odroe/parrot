import 'package:parrot/parrot.dart';

@Injectable()
class A {}

@Injectable()
class SimpleService {
  const SimpleService(this.a);

  final A a;

  void say() {
    print('Hello, 🦜 Parrot!');
  }
}

@Module(
  dependencies: [AppModule],
  providers: [SimpleService, A],
)
class SimpleModule {}

@Module(
  dependencies: [SimpleModule],
)
class AppModule {}

void main() async {
  final app = await ParrotApplication.create(AppModule);
  final module = await app.select(AppModule);

  print(module.metadata);

  // print(app.container.all);

  // final SimpleService service = app.resolve(SimpleService);

  // service.say(); // Hello, 🦜 Parrot!
}
