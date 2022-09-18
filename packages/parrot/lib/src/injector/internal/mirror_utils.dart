import 'dart:mirrors';

import '../../annotations/injectable.dart';

/// Find the factory method mirror.
MethodMirror findFactoryMethod(
  ClassMirror classMirror,
  Symbol factoryName,
) {
  final Symbol symbol = factoryName == Symbol.empty
      ? Symbol(classMirror.reflectedType.toString())
      : factoryName;

  final DeclarationMirror? declarationMirror = classMirror.declarations[symbol];
  if (declarationMirror != null && declarationMirror is MethodMirror) {
    // If the factory not is a constructor, throw an error.
    if (declarationMirror.isConstConstructor ||
        declarationMirror.isConstructor ||
        declarationMirror.isFactoryConstructor ||
        declarationMirror.isGenerativeConstructor ||
        declarationMirror.isRedirectingConstructor) {
      return declarationMirror;
    } else if (declarationMirror.isAbstract) {
      throw Exception('The provider factory $symbol must not be abstract.');
    } else if (declarationMirror.isPrivate) {
      throw Exception('The provider factory $symbol must not be private.');
    }

    throw Exception(
        'The factory method $symbol must be a constructor of the provider ${classMirror.reflectedType}.');
  }

  throw Exception(
      'The factory method $symbol does not exist in the class ${classMirror.reflectedType}.');
}

/// Resolve the parameter provider.
Future<Type> resolveParameterType(ParameterMirror parameter) async {
  final Iterable<Type> types = parameter.metadata
      .map((e) => e.reflectee)
      .whereType<Inject>()
      .map((Inject inject) => inject.type ?? parameter.type.reflectedType);

  // If types length is > 1, throw an error.
  if (types.length > 1) {
    throw Exception(
        'The parameter ${parameter.simpleName} has more than one @Inject annotation.');
  }

  return types.isEmpty ? parameter.type.reflectedType : types.first;
}

/// Resolve factory name.
Symbol resolveProviderFactoryName(ClassMirror classMirror) {
  final Iterable<Injectable> results = classMirror.metadata
      .map((InstanceMirror element) => element.reflectee)
      .whereType<Injectable>();

  if (results.length != 1) {
    throw Exception(
        'The provider ${classMirror.reflectedType} must have exactly one `@Injectable()` annotation.');
  }

  return results.first.factory;
}

/// Has injectable annotation.
bool hasInjectableAnnotation(TypeMirror mirror) {
  if (mirror is! ClassMirror) return false;

  return mirror.metadata.where((InstanceMirror annotation) {
    return annotation.reflectee is Injectable;
  }).isNotEmpty;
}
