import 'package:costealoo/services/auth_service.dart';
import 'package:costealoo/services/api_client.dart';

class DatabaseService {
  final ApiClient _apiClient = AuthService().apiClient;

  /// Create a new database
  Future<Map<String, dynamic>> createDatabase({
    required String name,
    required List<Map<String, dynamic>> products,
  }) async {
    try {
      final response = await _apiClient.post(
        '/Database',
        body: {'name': name, 'products': products},
        includeAuth: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all databases
  Future<List<Map<String, dynamic>>> getDatabases() async {
    try {
      final response = await _apiClient.get('/Database', includeAuth: true);

      if (response['data'] != null && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }

      return [];
    } catch (e) {
      // If 404 or empty, return empty list
      return [];
    }
  }
}
