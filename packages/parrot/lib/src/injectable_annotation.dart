/// Injectable annotation.
///
/// This annotation is used to mark a class as injectable.
///
/// Example:
/// ```dart
/// @Injectable() class Foo {} == @Injectable(factory: Foo.new) class Foo {}
///
/// // Specify a constructor or factory
/// @Injectable(
///   factory: Foo.custom,
/// )
/// class Foo {
///   const Demo.custom();
/// }
/// ```
class Injectable {
  const Injectable({
    this.factory,
  });

  /// The injectable class constructor or factory name.
  ///
  /// Defaults to the default constructor.
  final Function? factory;
}

/// Inject annotation.
class Inject {
  const Inject({
    this.token,
  });

  /// The injectable class token.
  ///
  /// Defaults to the injectable class type.
  final Object? token;
}
