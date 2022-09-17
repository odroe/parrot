import 'package:parrot/parrot.dart';
import 'package:parrot_01_inject/app.module.dart';
import 'package:parrot_01_inject/app.service.dart';

void main() async {
  final ParrotApplication app = await ParrotApplication.create(AppModule);

  final AppService service = await app.resolve(AppService);

  service.print(); // Hello, 🦜 Parrot!
}
