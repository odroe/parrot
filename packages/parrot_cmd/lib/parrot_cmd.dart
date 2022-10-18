library parrot.cmd;

import 'package:parrot/parrot.dart';

class _RegisterCommandWrapperModule implements Module {
  @override
  Set<Object> get exports => throw UnimplementedError();

  @override
  Set<Module> get imports => throw UnimplementedError();

  @override
  Set<Provider> get providers => throw UnimplementedError();
}

extension RegisterCommandExtension on Module {}
