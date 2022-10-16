import 'package:parrot/parrot.dart';
import 'package:parrot_commander/parrot_commander.dart';
import 'package:parrot_mirror/parrot_mirror.dart';

@Module(
  dependencies: {
    CommanderModule(name: 'parrot', description: 'Parrot commander example.'),
  },
)
class AppModule implements CommandRegistrar {
  @override
  Set<Object> get commands => throw UnimplementedError();
}

void main(List<String> args) async {
  final app = ParrotApplication(AppModule);

  // Init app
  await app.initialize(compiler);

  // Run app
  await app.run(args);
}
