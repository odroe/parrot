import 'injector/parrot_container.dart';

/// Parrot context.
///
/// The context is a container for modules.
abstract class ParrotContext {
  const ParrotContext(ParrotContainer container);

  /// Allows navigating through the modules tree, for example, to pull out a specific instance from the selected module.
  ParrotContext select(Type module);

  /// Retrieves an instance of either injectable or controller, otherwise, throws exception.
  Object get(Type typeOrToken);
}
