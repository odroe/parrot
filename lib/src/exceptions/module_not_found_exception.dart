class ModuleNotFoundException implements Exception {
  const ModuleNotFoundException(this.module);

  final Type module;
}
