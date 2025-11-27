import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  // Mock storage (static to persist across instances)
  static List<Map<String, dynamic>> _mockDatabases = [];
  static bool _isLoaded = false;

  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString('mock_databases');
    if (stored != null) {
      try {
        final List<dynamic> decoded = jsonDecode(stored);
        _mockDatabases = decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        // print('Error loading databases: $e');
      }
    }
    _isLoaded = true;
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mock_databases', jsonEncode(_mockDatabases));
  }

  /// Create a new database
  Future<Map<String, dynamic>> createDatabase({
    required String name,
    required List<Map<String, dynamic>> products,
  }) async {
    await _ensureLoaded();
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final newDb = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'products': products,
    };

    _mockDatabases.add(newDb);
    await _saveToPrefs();

    // Return success response
    return newDb;
  }

  /// Update a database (rename and update products)
  Future<void> updateDatabase({
    required String id,
    required String name,
    required List<Map<String, dynamic>> products,
  }) async {
    await _ensureLoaded();
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Update in mock list
    final index = _mockDatabases.indexWhere((db) => db['id'] == id);
    if (index != -1) {
      _mockDatabases[index]['name'] = name;
      _mockDatabases[index]['products'] = products;
      await _saveToPrefs();
    }
  }

  /// Get all databases
  Future<List<Map<String, dynamic>>> getDatabases() async {
    await _ensureLoaded();
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return List<Map<String, dynamic>>.from(_mockDatabases);
  }

  /// Delete a database
  Future<void> deleteDatabase(String id) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 500));

    _mockDatabases.removeWhere((db) => db['id'] == id);
    await _saveToPrefs();
  }
}
