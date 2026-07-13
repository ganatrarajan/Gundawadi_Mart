import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../services/shared_prefs_service.dart';
import 'mock_interceptor.dart';

class DioClient {
  late final Dio _dio;

  // Toggle this flag to switch between the live Laravel REST backend and mock data
  static const bool useMockData = false;

  DioClient() {
    final baseOptions = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
      headers: {
        'Accept': 'application/json',
      },
    );

    _dio = Dio(baseOptions);

    // Authentication header injector interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = SharedPrefsService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    // Logger interceptor in debug mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    // Register MockInterceptor if enabled
    if (useMockData) {
      _dio.interceptors.add(MockInterceptor());
    }
  }

  Dio get dio => _dio;
}
