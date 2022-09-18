import '../http/http_method.dart';

abstract class MiddlewareConfigure {
  void forController(Type controller, {bool exclude = false});

  void forRoute(String path,
      {HttpMethod method = HttpMethod.all, bool exclude = false});

  void forMethod(HttpMethod method, {bool exclude = false});
}
