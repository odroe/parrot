import 'dart:mirrors';

List<MethodMirror> findConstructors(ClassMirror clazz) {
  return clazz.declarations.values
      .whereType<MethodMirror>()
      .where((method) => method.isConstructor)
      .toList();
}
