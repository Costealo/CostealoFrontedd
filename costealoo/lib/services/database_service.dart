import 'package:costealoo/services/auth_service.dart';

class DatabaseService {
  final _authService = AuthService();

  /// Create a new database
  /// status: 0 = Draft, 1 = Published (defaults to Draft if not provided)
  Future<Map<String, dynamic>> createDatabase({
    required String name,
    required List<Map<String, dynamic>> products,
    int? status, // 0 = Draft, 1 = Published
  }) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    // 1. Create the database header
    // Backend extracts UserId from JWT token automatically.
    // CreatePriceDatabaseDto accepts: Name (required), Status (optional, defaults to 0)
    final requestBody = {'Name': name, if (status != null) 'Status': status};

    print('DEBUG - Creating database with body: $requestBody');

    final response = await _authService.apiClient.post(
      '/PriceDatabase',
      body: requestBody,
      includeAuth: true,
    );

    final newDbId = response['id'];

    // 2. Add items if any (Parallel execution)
    if (products.isNotEmpty) {
      final futures = products.map((product) {
        return _authService.apiClient.post(
          '/PriceDatabase/$newDbId/items',
          body: {
            'Product': product['name'],
            'Price': product['price'],
            'Unit': product['unit'],
          },
          includeAuth: true,
        );
      });
      await Future.wait(futures);
    }

    return {
      'id': newDbId.toString(),
      'name': name,
      'products': products,
      'status': status ?? 0,
    };
  }

  /// Update a database (rename and update products)
  Future<void> updateDatabase({
    required String id,
    required String name,
    required List<Map<String, dynamic>> products,
    int? status,
  }) async {
    final user = _authService.currentUser;
    final body = {
      'id': int.parse(id),
      'name': name,
      'userId': user?.id,
      if (status != null) 'status': status,
    };

    print('DEBUG - updateDatabase body: $body'); // Debug log

    await _authService.apiClient.put(
      '/PriceDatabase/$id',
      body: body,
      includeAuth: true,
    );

    final existingDb = await _authService.apiClient.get(
      '/PriceDatabase/$id',
      includeAuth: true,
    );
    final existingItems = (existingDb['items'] as List<dynamic>?) ?? [];

    // Delete existing items in parallel
    if (existingItems.isNotEmpty) {
      final deleteFutures = existingItems.map((item) {
        return _authService.apiClient.delete(
          '/PriceDatabase/$id/items/${item['id']}',
          includeAuth: true,
        );
      });
      await Future.wait(deleteFutures);
    }

    // Create new items in parallel
    if (products.isNotEmpty) {
      final createFutures = products.map((product) {
        return _authService.apiClient.post(
          '/PriceDatabase/$id/items',
          body: {
            'Product': product['name'],
            'Price': product['price'],
            'Unit': product['unit'],
          },
          includeAuth: true,
        );
      });
      await Future.wait(createFutures);
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
    print('DEBUG - getDatabases response data: $data');

    return data.map((db) {
      print(
        'DEBUG - Processing database: ${db['name']}, items: ${db['items']}',
      );
      return {
        'id': db['id'].toString(),
        'name': db['name'],
        'status': _parseStatus(db['status']), // Parse status safely
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

  /// Publish a draft database (change status from 0 to 1)
  Future<void> publishDatabase(String id) async {
    await _authService.apiClient.put(
      '/PriceDatabase/$id/publish',
      body: {},
      includeAuth: true,
    );
  }

  /// Delete a database
  Future<void> deleteDatabase(String id) async {
    await _authService.apiClient.delete(
      '/PriceDatabase/$id',
      includeAuth: true,
    );
  }

  int _parseStatus(dynamic status) {
    if (status == null) return 0;
    if (status is int) return status;
    if (status is String) {
      final s = status.trim().toLowerCase();
      if (s == 'published' || s == '1') return 1;
      return 0; // 'Draft' or others
    }
    return 0;
  }
}
