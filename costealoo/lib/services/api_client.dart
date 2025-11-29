import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Azure API base URL
  // static const String baseUrl = 'https://app-251126163117.azurewebsites.net/api';
  static const String baseUrl = 'http://localhost:5150/api';

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? getToken() => _token;

  Map<String, String> _getHeaders({bool includeAuth = false}) {
    final headers = {'Content-Type': 'application/json'};

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool includeAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
        body: jsonEncode(body),
      );

      // Check status code first
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle empty or non-JSON responses
        if (response.body.isEmpty) {
          return {}; // Return empty map for empty responses
        }

        try {
          // Try to parse as JSON
          final responseData = jsonDecode(response.body);

          // Handle if response is a plain string (like for login token)
          if (responseData is String) {
            return {'token': responseData};
          }

          return responseData as Map<String, dynamic>;
        } catch (e) {
          // If not JSON, treat response body as a string value
          return {'data': response.body};
        }
      } else {
        // Handle error responses
        print('ERROR Response (${response.statusCode}): ${response.body}');
        Map<String, dynamic>? errorData;
        try {
          errorData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          // If error response is not JSON, use the raw body
          throw ApiException(
            message: response.body.isNotEmpty
                ? response.body
                : 'Error del servidor (${response.statusCode})',
            statusCode: response.statusCode,
          );
        }

        throw ApiException(
          message:
              errorData['message'] as String? ??
              errorData['error'] as String? ??
              errorData['title'] as String? ??
              'Error desconocido',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool includeAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('GET Request: $url');
      final response = await http.get(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
      );
      print('GET Response (${response.statusCode}): ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {};
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return {'data': decoded};
        }
        return decoded as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: 'Error ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('GET Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool includeAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle empty responses (204 No Content)
        if (response.body.isEmpty) {
          return {}; // Return empty map for empty responses
        }

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return responseData;
      } else {
        // Handle error responses
        print('ERROR Response (${response.statusCode}): ${response.body}');
        Map<String, dynamic>? errorData;
        try {
          errorData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw ApiException(
            message: response.body.isNotEmpty
                ? response.body
                : 'Error del servidor (${response.statusCode})',
            statusCode: response.statusCode,
          );
        }

        throw ApiException(
          message:
              errorData['message'] as String? ??
              errorData['error'] as String? ??
              errorData['title'] as String? ??
              'Error desconocido',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool includeAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle empty responses (204 No Content)
        if (response.body.isEmpty) {
          return {}; // Return empty map for empty responses
        }

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return responseData;
      } else {
        // Handle error responses
        print('ERROR Response (${response.statusCode}): ${response.body}');
        Map<String, dynamic>? errorData;
        try {
          errorData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw ApiException(
            message: response.body.isNotEmpty
                ? response.body
                : 'Error del servidor (${response.statusCode})',
            statusCode: response.statusCode,
          );
        }

        throw ApiException(
          message:
              errorData['message'] as String? ??
              errorData['error'] as String? ??
              errorData['title'] as String? ??
              'Error desconocido',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error de conexión: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}
