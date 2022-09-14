import '../injector/scope.dart';

/// Injectable annotation.
///
/// A class annotated with `@Injectable()` can be injected.
///
/// Example:
/// ```dart
/// @Injectable()
/// class UserService {}
/// ```
///
/// You can also specify the scope of the service:
/// ```dart
/// @Injectable(scope: Scope.singleton)
/// class UserService {}
/// ```
///
/// If your service has multiple factories, you can assign a factory
/// to Parrot (**Note**: the factory method name cannot be a private
/// property starting with `_`):
/// ```dart
/// @Injectable(factory: 'create')
/// class UserService {
///  UserService._();
///  factory UserService.create() => UserService._();
/// }
/// ```
class Injectable {
  const Injectable({
    this.scope = Scope.singleton,
    this.factory,
  });

  /// The scope of the service.
  /// Default is [Scope.singleton].
  final Scope scope;

  /// The factory method name.
  final String? factory;
}

/// Inject annotation.
///
/// Inject into a class member.
///
/// Example:
/// ```dart
/// @Injectable()
/// class UserService {}
///
/// @Injectable()
/// class PostService {
///   @Inject()
///   late final UserService userService;
/// }
/// ```
class Inject {
  const Inject([this.token]);

  /// The token of the service.
  final Object? token;
}
