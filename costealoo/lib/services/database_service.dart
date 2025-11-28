import 'package:costealoo/services/auth_service.dart';

class DatabaseService {
  final _authService = AuthService();

  /// Create a new database
  Future<Map<String, dynamic>> createDatabase({
    required String name,
    required List<Map<String, dynamic>> products,
  }) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    // 1. Create the database header
    // Sending Name and UserId.
    // NOTE: This is the correct implementation. It will fail with 400 until the backend
    // is updated to use a DTO that doesn't require the full User object.
    final requestBody = {'Name': name, 'UserId': user.id};

    print('DEBUG - Creating database with body: $requestBody');

    final response = await _authService.apiClient.post(
      '/PriceDatabase',
      body: requestBody,
      includeAuth: true,
    );

    final newDbId = response['id'];

    // 2. Add items if any
    if (products.isNotEmpty) {
      for (var product in products) {
        await _authService.apiClient.post(
          '/PriceDatabase/$newDbId/items',
          body: {
            'product': product['name'],
            'price': product['price'],
            'unit': product['unit'],
          },
          includeAuth: true,
        );
      }
    }

    return {'id': newDbId.toString(), 'name': name, 'products': products};
  }

  /// Update a database (rename and update products)
  Future<void> updateDatabase({
    required String id,
    required String name,
    required List<Map<String, dynamic>> products,
  }) async {
    await _authService.apiClient.put(
      '/PriceDatabase/$id',
      body: {'name': name},
      includeAuth: true,
    );

    final existingDb = await _authService.apiClient.get(
      '/PriceDatabase/$id',
      includeAuth: true,
    );
    final existingItems = (existingDb['items'] as List<dynamic>?) ?? [];

    for (var item in existingItems) {
      await _authService.apiClient.delete(
        '/PriceDatabase/$id/items/${item['id']}',
        includeAuth: true,
      );
    }

    for (var product in products) {
      await _authService.apiClient.post(
        '/PriceDatabase/$id/items',
        body: {
          'product': product['name'],
          'price': product['price'],
          'unit': product['unit'],
        },
        includeAuth: true,
      );
    }
  }

  /// Get all databases
  Future<List<Map<String, dynamic>>> getDatabases() async {
    final response = await _authService.apiClient.get(
      '/PriceDatabase',
      includeAuth: true,
    );

    if (response is List) {
      return [];
    }

    final List<dynamic> data = response['data'] ?? [];

    return data.map((db) {
      return {
        'id': db['id'].toString(),
        'name': db['name'],
        'products':
            (db['items'] as List<dynamic>?)?.map((item) {
              return {
                'name': item['product'],
                'price': item['price'],
                'unit': item['unit'],
              };
            }).toList() ??
            [],
      };
    }).toList();
  }

  /// Delete a database
  Future<void> deleteDatabase(String id) async {
    await _authService.apiClient.delete(
      '/PriceDatabase/$id',
      includeAuth: true,
    );
  }
}
