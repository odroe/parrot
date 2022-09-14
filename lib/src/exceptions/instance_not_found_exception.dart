class InstanceNotFoundException implements Exception {
  const InstanceNotFoundException(this.type);

  final Type type;
}
