// import 'dart:mirrors';

// class ProviderC

// import '../annotations/injectable.dart';
// import 'any_compiler.dart';
// import 'any_compiler_runner.dart';
// import 'provider_context.dart';
// import 'scope.dart';
// import 'scoped_providers/request_provider_context.dart';
// import 'scoped_providers/singleton_provider_context.dart';
// import 'scoped_providers/transient_provider_context.dart';

// mixin ProviderCompiler on InjectableAnnotation
//     implements AnyCompiler<ProviderContext> {
//   @override
//   Iterable<Type> get uses => const <Type>[];

//   @override
//   Future<ProviderContext> compile(
//       AnyCompilerRunner runner, Mirror mirror) async {
//     // If the mirror not a class mirror, throw an error.
//     if (mirror is! ClassMirror) {
//       throw Exception(
//           'The `@Injectable()` annotation can only be used on a class.');
//     }

//     // If the mirror find in contianer, return the context.
//     if (runner.container.has(mirror.reflectedType)) {
//       return runner.container.get(mirror.reflectedType)!.value;
//     }

//     // Create a new context.
//     final ProviderContext context = createContext(mirror);

//     // Add the context to the container.
//     runner.container.set(ParrotToken(mirror.reflectedType, context));

//     return context;
//   }

//   /// Create a new [ProviderContext] instance.
//   ProviderContext createContext(ClassMirror mirror) {
//     switch (scope) {
//       case Scope.request:
//         return createRequestScopeContext(mirror);
//       case Scope.transient:
//         return createTransientScopeContext(mirror);
//       case Scope.singleton:
//         return createSingletonScopeContext(mirror);
//     }
//   }

//   /// Create a new [RequestProviderContext] instance.
//   RequestProviderContext createRequestScopeContext(ClassMirror mirror) {
//     final TransientProviderContext context =
//         createTransientScopeContext(mirror);

//     return RequestProviderContext(
//       modules: context.modules,
//       type: mirror.reflectedType,
//       value: context.value,
//     );
//   }

//   /// Create a new [TransientProviderContext] instance.
//   TransientProviderContext createTransientScopeContext(ClassMirror mirror) {
//     throw UnimplementedError();
//   }

//   /// Create singleton scope context.
//   SingletonProviderContext createSingletonScopeContext(ClassMirror mirror) {
//     final Symbol factorySymbol = findFactorySymbol(mirror);

//     print(factorySymbol);
//     throw UnimplementedError();
//   }

//   /// Find the factory symbol.
//   Symbol findFactorySymbol(ClassMirror mirror) {
//     return Symbol(factory ?? mirror.reflectedType.toString());
//     // mirror.qualifiedName
//     // final String name = factory ?? mirror.reflectedType.;
//   }
// }
