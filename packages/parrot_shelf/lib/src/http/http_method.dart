enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete,
  head,
  options,
  trace,
  connect,
  all;

  @override
  String toString() => name.toUpperCase();
}
