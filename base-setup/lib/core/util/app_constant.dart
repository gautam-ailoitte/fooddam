import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstant {
  static const String appName = "Guardian Bubble";

  static const String authorization = "Authorization";
  static const String userIp = "x-user-ip";
  static const String systemInfo = "x-system-info";

  static const String serverDateFormat = "yyyy-MM-dd";
  static const String serverIsoUtcWithMilliseconds =
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  static const String errorNoInternet = "No internet available";
  static const String errorUnknown = "Unknown error occurred";

  static String baseApiUrl = dotenv.env['BASE_API_URL'] ?? '';
  static String apiKey = dotenv.env['API_KEY'] ?? '';
}
