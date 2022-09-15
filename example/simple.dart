import 'dart:mirrors';

import 'package:parrot/parrot.dart';
import 'package:parrot/src/injector/any_compiler.dart';
import 'package:parrot/src/injector/any_compiler_runner.dart';

@Module(dependencies: [SimpleModule])
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

class Demo implements AnyCompiler {
  const Demo();

  @override
  Iterable<Type> get uses => [Module];

  @override
  Future<void> compile(AnyCompilerRunner runner, Mirror mirror) async {}
}

void main() async {
  final app = ParrotApplication(AppModule);

  await app.initialize();

  print(app.container.all);

  // print(app.select(UserModule).module);
  // final SimpleService service = app.resolve(SimpleService);

  // service.say(); // Hello, 🦜 Parrot!
}
