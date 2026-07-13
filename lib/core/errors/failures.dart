import 'dart:convert';
import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'A server error occurred. Please try again.']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No Internet connection. Please check your network.']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache operation failed.']) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

class ErrorParser {
  static String parse(dynamic e, String defaultMessage) {
    if (e is! DioException) return e.toString();
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data.containsKey('message')) {
          return data['message'].toString();
        } else if (data.containsKey('error')) {
          return data['error'].toString();
        }
      } else if (data is String) {
        try {
          final parsed = jsonDecode(data);
          if (parsed is Map) {
            if (parsed.containsKey('message')) {
              return parsed['message'].toString();
            } else if (parsed.containsKey('error')) {
              return parsed['error'].toString();
            }
          }
        } catch (_) {
          if (data.trim().isNotEmpty) {
            return data;
          }
        }
      }
    }
    return defaultMessage;
  }
}
