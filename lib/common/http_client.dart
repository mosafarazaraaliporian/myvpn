import 'package:dio/dio.dart';

// Firebase URL (ثابت - هیچوقت تغییر نمیکنه)
const String FIREBASE_URL = 'https://testrt-fa9d3-default-rtdb.firebaseio.com';

// Dio instance برای Firebase
final firebaseClient = Dio(
  BaseOptions(
    baseUrl: FIREBASE_URL,
    headers: {
      'X-Content-Type-Options': 'nosniff',
    },
  ),
);

// Dio instance برای Worker (URL از Firebase میاد)
late final Dio httpClient;

// تابع برای دریافت Worker URL از Firebase و initialize کردن httpClient
Future<void> initializeHttpClient() async {
  try {
    // دریافت config از Firebase
    final response = await firebaseClient.get('/config.json');
    final config = response.data;
    
    // دریافت domain از config
    final String workerUrl = config['domain'] ?? 'https://pingo-vpn-api.mpouanfar.workers.dev';
    
    // Initialize httpClient با URL دینامیک
    httpClient = Dio(
      BaseOptions(
        baseUrl: 'https://$workerUrl',
        headers: {
          'X-Content-Type-Options': 'nosniff',
        },
      ),
    );
    
    print('🌐 Worker URL initialized: https://$workerUrl');
  } catch (e) {
    print('⚠️ Failed to get Worker URL from Firebase, using default');
    // اگر Firebase در دسترس نبود، از URL پیش‌فرض استفاده کن
    httpClient = Dio(
      BaseOptions(
        baseUrl: 'https://pingo-vpn-api.mpouanfar.workers.dev',
        headers: {
          'X-Content-Type-Options': 'nosniff',
        },
      ),
    );
  }
}

