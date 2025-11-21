import 'package:costealoo/services/auth_service.dart';
import 'package:costealoo/services/api_client.dart';

class DatabaseService {
  final ApiClient _apiClient = AuthService().apiClient;

  // Mock storage (static to persist across instances)
  static final List<Map<String, dynamic>> _mockDatabases = [];

  /// Create a new database
  Future<Map<String, dynamic>> createDatabase({
    required String name,
    required List<Map<String, dynamic>> products,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final newDb = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'products': products,
    };

    _mockDatabases.add(newDb);

    // Return success response
    return newDb;

    /* 
    // API Implementation (Commented out until backend is ready)
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
    */
  }

  /// Update a database (e.g. rename)
  Future<void> updateDatabase({
    required String id,
    required String name,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Update in mock list
    final index = _mockDatabases.indexWhere((db) => db['id'] == id);
    if (index != -1) {
      _mockDatabases[index]['name'] = name;
    }

    /*
    // API Implementation
    try {
      await _apiClient.put(
        '/Database/$id',
        body: {'name': name},
        includeAuth: true,
      );
    } catch (e) {
      rethrow;
    }
    */
  }

  /// Get all databases
  Future<List<Map<String, dynamic>>> getDatabases() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return List<Map<String, dynamic>>.from(_mockDatabases);

    /*
    // API Implementation (Commented out until backend is ready)
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
    */
  }
}
