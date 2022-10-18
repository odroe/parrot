import 'package:parrot/parrot.dart';

name(ref) => 'Parrot';
hello(ref) => 'Hello ${ref(name)}';

final root = Module(
  providers: {name, hello},
);

void main() async {
  final app = Parrot(root);

  print(await app.resolve(hello));
}
