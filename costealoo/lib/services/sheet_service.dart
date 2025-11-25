import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SheetService {
  // Mock storage (static to persist across instances)
  static List<Map<String, dynamic>> _mockSheets = [];
  static bool _isLoaded = false;

  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString('mock_sheets');
    if (stored != null) {
      try {
        final List<dynamic> decoded = jsonDecode(stored);
        _mockSheets = decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        // print('Error loading sheets: $e');
      }
    }
    _isLoaded = true;
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mock_sheets', jsonEncode(_mockSheets));
  }

  /// Create a new sheet
  Future<Map<String, dynamic>> createSheet(
    Map<String, dynamic> sheetData,
  ) async {
    await _ensureLoaded();
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final newSheet = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      ...sheetData,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _mockSheets.add(newSheet);
    await _saveToPrefs();

    // Return success response
    return newSheet;
  }

  /// Get all sheets
  Future<List<Map<String, dynamic>>> getSheets() async {
    await _ensureLoaded();
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return List<Map<String, dynamic>>.from(_mockSheets);
  }

  /// Update a sheet (e.g. rename)
  Future<void> updateSheet(String id, Map<String, dynamic> updates) async {
    await _ensureLoaded();
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockSheets.indexWhere((s) => s['id'] == id);
    if (index != -1) {
      _mockSheets[index] = {..._mockSheets[index], ...updates};
      await _saveToPrefs();
    }
  }
}
