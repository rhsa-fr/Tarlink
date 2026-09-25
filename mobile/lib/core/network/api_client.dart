import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? error;

  ApiException({
    required this.statusCode,
    required this.message,
    this.error,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Centralized REST API Client for Tarlink Mobile App.
/// Pure HTTP communication with Next.js Backend. No hardcoded mock data.
class ApiClient {
  ApiClient._();

  static String _baseUrl = _resolveDefaultBaseUrl();
  static String? _authToken;
  static http.Client? _httpClient;

  static void setHttpClient(http.Client? client) {
    _httpClient = client;
  }

  static http.Client get clientInstance => _httpClient ?? http.Client();

  static String _resolveDefaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:3000/api/v1';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api/v1';
    } catch (_) {}
    return 'http://localhost:3000/api/v1';
  }

  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static Map<String, String> _buildHeaders([Map<String, String>? extra]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  static Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final cleanBase = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    var uri = Uri.parse('$cleanBase$cleanEndpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      final merged = Map<String, String>.from(uri.queryParameters)..addAll(queryParams);
      uri = uri.replace(queryParameters: merged);
    }
    return uri;
  }

  static Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = _buildUri(endpoint, queryParams);
    try {
      final response = await clientInstance.get(uri, headers: _buildHeaders()).timeout(
        const Duration(seconds: 10),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 503,
        message: 'Gagal terhubung ke backend Tarlink: ${e.toString()}',
      );
    }
  }

  static Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = _buildUri(endpoint);
    try {
      final response = await clientInstance
          .post(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 503,
        message: 'Gagal terhubung ke backend Tarlink: ${e.toString()}',
      );
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    }

    final message = body is Map<String, dynamic>
        ? (body['message'] ?? 'Terjadi kesalahan pada server')
        : 'HTTP Error ${response.statusCode}';
    final error = body is Map<String, dynamic> ? body['error'] : null;

    throw ApiException(
      statusCode: response.statusCode,
      message: message.toString(),
      error: error?.toString(),
    );
  }
}
