import 'package:dio/dio.dart';

final httpClient = Dio(
  BaseOptions(
    baseUrl: 'https://tight-term-75a4.mpouanfar.workers.dev',
    headers: {
      'X-Content-Type-Options': 'nosniff',
    },
  ),
);
