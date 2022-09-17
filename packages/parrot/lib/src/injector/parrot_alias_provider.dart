/// Alias provider for [Module].
///
/// This provider is used to create an alias for a provider.
///
/// Example:
/// ```dart
/// final loggerAliasProvider = ParrotAliasProvider(
///   provide: Logger,
///   useExisting: ConsoleLogger,
/// );
///
/// @Module(
///  providers: [loggerAliasProvider],
/// )
/// class MyModule {}
///
/// final app = await ParrotApplication.create(MyModule);
///
/// final Logger logger = await app.resolve(Logger);
///
/// print(logger is ConsoleLogger); // true
/// ```
/// TODO: implement alias provider
class ParrotAliasProvider {
  const ParrotAliasProvider({
    required this.provide,
    required this.existing,
  });

  final Object provide;
  final Type existing;
}
