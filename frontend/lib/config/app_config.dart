class AppConfig {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  static const String chapaWebViewUrl = String.fromEnvironment(
    'CHAPA_WEBVIEW_URL',
    defaultValue: 'https://api.chapa.co',
  );

  // App Configuration
  static const String appName = 'Campus Eats';
  static const String appVersion = '2.0.0';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // Commission Rate
  static const double commissionRate = 0.05;

  // OTP Configuration
  static const int otpLength = 6;
  static const int otpResendDelay = 60; // seconds

  // Order Refresh Interval
  static const int orderRefreshInterval = 30; // seconds

  // Local Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyFcmToken = 'fcm_token';

  // Hive Box Names
  static const String hiveBoxUser = 'user_box';
  static const String hiveBoxOrders = 'orders_box';
  static const String hiveBoxCart = 'cart_box';

  // Firebase
  static const String fcmTopicOrders = 'orders';
  static const String fcmTopicPromotions = 'promotions';
}
