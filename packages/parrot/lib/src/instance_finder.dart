import 'package:parrot/src/instance_definition.dart';

abstract class InstanceFinder {
  const InstanceFinder();

  /// Find a instance definition.
  InstanceDefinition find(Object identifier, [Object? inquirer]);
}
