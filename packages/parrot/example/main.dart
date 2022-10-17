import 'package:parrot/parrot.dart';

String hello(ref) => 'Hello';
String world(ref) => 'Parrot';

// Create a say provider.
void Function() say(ModuleRef ref) =>
    () => print('${ref(hello)}, ${ref(world)}!');

// Define a root module.
final root = Module(
  providers: {hello, world, say},
);

void main(List<String> args) async {
  // Create a new parrot application.
  final app = Parrot(root);

  final sayCall = await app.resolve(say);

  sayCall(); // Hello, Parrot!
}
