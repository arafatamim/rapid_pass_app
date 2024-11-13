enum AppExceptionType {
  network,
  server,
  invalidLocale,
  unknown,
}

class AppException implements Exception {
  final AppExceptionType code;

  AppException(this.code);

  @override
  String toString() {
    return "Error code: $code";
  }
}
