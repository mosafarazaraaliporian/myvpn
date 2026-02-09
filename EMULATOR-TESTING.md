# راهنمای تست روی Emulator

## تنظیمات Test Mode

فایل `lib/common/config.dart` رو باز کن و مطمئن شو که:

```dart
static const bool isTestMode = true;  // برای emulator
static const bool enableDebugLogs = true;  // برای دیدن لاگ‌ها
```

## اجرای اپ روی Emulator

### روش 1: Android Studio
1. Emulator رو باز کن
2. در ترمینال پروژه بزن:
```bash
cd BegzarApp
flutter run
```

### روش 2: VS Code
1. Emulator رو باز کن
2. F5 بزن یا از منوی Run > Start Debugging استفاده کن

## مشاهده لاگ‌ها

لاگ‌های اپ با emoji 🐦 شروع میشن. برای دیدن لاگ‌ها:

```bash
# در Android Studio
# پنجره Logcat رو باز کن و فیلتر کن روی "Pingo"

# یا در ترمینال
adb logcat | grep "🐦"
```

## لاگ‌های مهم

وقتی اپ اجرا میشه، باید این لاگ‌ها رو ببینی:

```
🐦 Pingo: Starting app...
🐦 JailBreak check: false
🐦 EasyLocalization initialized
🐦 Running app...
🐦 Pingo: initState started
🐦 Test Mode: true
🐦 Running in TEST MODE - VPN disabled
🐦 Pingo: initState completed
```

## رفع مشکلات

### اگر اپ کرش کرد:
1. لاگ‌ها رو چک کن ببین کجا خطا داده
2. مطمئن شو `isTestMode = true` هست
3. اپ رو rebuild کن: `flutter clean && flutter run`

### اگر دکمه Connect کار نکرد:
در حالت تست، وقتی دکمه Connect رو میزنی باید یک پیغام نارنجی ببینی که میگه:
```
TEST MODE: VPN disabled on emulator
```

### اگر SafeDevice مشکل داره:
در `main.dart` چک SafeDevice رو با try-catch گرفتیم، پس نباید مشکلی ایجاد کنه.

## تست قبل از Production

قبل از اینکه اپ رو برای production بیلد بگیری:

1. `isTestMode` رو به `false` تغییر بده
2. `enableDebugLogs` رو به `false` تغییر بده
3. یک بار روی دستگاه واقعی تست کن

## نکات مهم

- در حالت تست، VPN واقعی اجرا نمیشه
- همه چیز فقط برای نمایش UI هست
- برای تست واقعی VPN، باید روی دستگاه فیزیکی اجرا کنی
- Emulator نمیتونه VPN واقعی اجرا کنه
