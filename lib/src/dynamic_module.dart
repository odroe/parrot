import 'annotations/module.dart';

/// Dynamic module.
///
/// Dynamic modules are used to wrap the specified module and provide a wrapper for the specified module.
///
/// Example:
/// ```dart
/// class PrismaService extends PrismaClient {
///   PrismaService(@Inject(PrismaModule.token) String url): super(
///     datasources: Datasources(
///       db: Datasource(url: url),
///     ),
///   );
/// }
///
/// @Module(
///   providers: [PrismaService],
/// )
/// class PrismaModule {
///   static const Symbol token = #PRISMA_DB_URL;
/// }
///
///
/// @Module(
///   dependencies: [PrismaModule],
/// )
/// class AppModule {}
/// ```
class DynamicModule extends Module {
  const DynamicModule({
    required this.module,
    super.dependencies,
    super.exports,
    super.providers,
  });

  /// The dynamic module child module token.
  final Object module;
}
