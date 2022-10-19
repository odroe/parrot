import 'package:parrot/parrot.dart';
import 'package:parrot_cmd/parrot_cmd.dart';

final sayCommand =
    createClosureCommand('say', 'Say something', (result, ref) async {
  print('Hello, Parrot!');
});

final root = Module(
  providers: {sayCommand},
).useCommands([sayCommand]);

void main(List<String> args) {
  final app = Parrot(root);

  app.run(args);
}
