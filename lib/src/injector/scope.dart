/// Injectable scopes.
enum Scope {
  /// A single instance of the dependency is created for the lifetime of the
  /// application.
  ///
  /// This is the default scope.
  singleton,

  /// A new instance of the dependency is created each time it is injected.
  transient,

  /// A new instance of the provider is created exclusively for each incoming
  /// request. The instance is garbage-collected after the request has
  /// completed processing.
  request,
}
