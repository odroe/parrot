import 'instance_definition.dart';
import 'instance_finder.dart';
import 'module_definition.dart';

abstract class ApplicationInitiator {
  /// Returns the application bindings module definition.
  ModuleDefinition get definition;

  /// Sets the application bindings module definition.
  set definition(ModuleDefinition definition);
}

abstract class ParrotApplication extends InstanceFinder {
  factory ParrotApplication(Object module) = _ParrotApplicationImpl;

  /// The application bindings module.
  Object get module;
}

class _ParrotApplicationImpl
    implements ParrotApplication, ApplicationInitiator {
  _ParrotApplicationImpl(this.module);

  @override
  final Object module;

  @override
  late final ModuleDefinition definition;

  @override
  InstanceDefinition find(Object identifier, [Object? inquirer]) =>
      definition.find(identifier, inquirer);
}
