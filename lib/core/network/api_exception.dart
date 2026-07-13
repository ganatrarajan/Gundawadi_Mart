import 'dart:convert';
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioError(DioException dioError) {
    String message = "Something went wrong. Please try again.";
    
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = "Request to the API server was cancelled.";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with the API server.";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with the API server.";
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with the API server.";
        break;
      case DioExceptionType.badResponse:
        final response = dioError.response;
        if (response != null) {
          final data = response.data;
          if (data is Map) {
            if (data.containsKey('message')) {
              message = data['message'].toString();
            } else if (data.containsKey('error')) {
              message = data['error'].toString();
            } else {
              message = "Server error code: ${response.statusCode}";
            }
          } else if (data is String) {
            try {
              final parsed = json.decode(data);
              if (parsed is Map) {
                if (parsed.containsKey('message')) {
                  message = parsed['message'].toString();
                } else if (parsed.containsKey('error')) {
                  message = parsed['error'].toString();
                }
              } else {
                message = data;
              }
            } catch (_) {
              message = data;
            }
          } else {
            message = "Server error code: ${response.statusCode}";
          }
        }
        break;
      case DioExceptionType.connectionError:
        message = "No internet connection. Please verify your network.";
        break;
      default:
        message = "Unexpected networking issue. Please try again.";
        break;
    }
    
    return ApiException(
      message: message,
      statusCode: dioError.response?.statusCode,
    );
  }

  @override
  String toString() => message;
}
