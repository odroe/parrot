import 'package:parrot_shelf/parrot_shelf.dart';

import 'app.service.dart';

@Controller()
class AppController {
  const AppController(this.service);

  final AppService service;

  @Get()
  hello() => 'Hello, ${service.name}!';
}
