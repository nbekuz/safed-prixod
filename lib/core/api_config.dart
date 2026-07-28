/// Safet Pick — order picking app API configuration.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://apies.firepole.ru/api/v1/';

  static const String wsBaseUrl = 'wss://apies.firepole.ru/';

  static const String brandName = 'Safet';

  /// User-facing app name (home screen, profile, task switcher).
  static const String appDisplayName = 'Safet Pick';
}
