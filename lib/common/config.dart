/// تنظیمات عمومی اپلیکیشن
class AppConfig {
  /// حالت تست - برای emulator و تست بدون VPN
  /// در production باید false باشه
  static const bool isTestMode = true; // تغییر بده به false برای production
  
  /// نمایش لاگ‌های debug
  static const bool enableDebugLogs = true;
  
  /// تایم‌اوت درخواست‌ها (ثانیه)
  static const int requestTimeout = 10;
}
