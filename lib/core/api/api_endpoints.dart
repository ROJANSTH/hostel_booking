import 'dart:io';

class ApiEndpoints {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static String get authBase => '$baseUrl/api/v1/auth';

  static String get register => '$authBase/register';
  static String get login => '$authBase/login';
}
