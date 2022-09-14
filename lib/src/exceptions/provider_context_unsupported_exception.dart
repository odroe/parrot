class ProviderContextUnsupportedException implements Exception {
  final String method;

  ProviderContextUnsupportedException(this.method);
}
