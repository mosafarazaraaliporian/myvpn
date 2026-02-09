import 'package:dio/dio.dart';

final httpClient = Dio(
  BaseOptions(
    // TODO: Replace with your Cloudflare Worker URL after deployment
    // Example: 'https://begzar-vpn-api.your-subdomain.workers.dev'
    baseUrl: 'https://your-worker.workers.dev',
    headers: {
      'X-Content-Type-Options': 'nosniff',
    },
  ),
);
