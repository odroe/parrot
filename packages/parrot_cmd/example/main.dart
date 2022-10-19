import 'package:parrot/parrot.dart';
import 'package:parrot_cmd/parrot_cmd.dart';

/// Create a command.
final sayCommand = createClosureCommand('say', 'Say something', (result, ref) {
  print('Hello, Parrot!');
});

// Create a root module.
final root = Module().useCommand(sayCommand);

void main(List<String> args) {
  // Create a Parrot application.
  final app = Parrot(root);

  // Run command-line application.
  app.run(args);
}
