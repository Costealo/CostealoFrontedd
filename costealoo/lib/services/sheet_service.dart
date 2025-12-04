import 'package:costealoo/services/auth_service.dart';

class SheetService {
  final _authService = AuthService();

  /// Create a new sheet (Workbook)
  Future<Map<String, dynamic>> createSheet(
    Map<String, dynamic> sheetData,
  ) async {
    // 1. Create Workbook Header
    // Parse margin string "25.00 %" -> 25.00
    String marginStr = sheetData['margin']?.toString() ?? '0';
    marginStr = marginStr.replaceAll('%', '').trim();
    marginStr = marginStr.replaceAll(',', '.'); // Handle comma decimal
    final margin = double.tryParse(marginStr) ?? 0.0;

    // Get status, default to 0 (draft) if not provided
    final status = sheetData['status'] ?? 0;
    print('DEBUG - Creating workbook with status: $status'); // Debug log

    final headerBody = {
      'name': sheetData['name'],
      'productionUnits': sheetData['productQty'] ?? 1.0,
      'taxPercentage': 16.0,
      'profitMarginPercentage': margin,
      'targetSalePrice': sheetData['salePrice'],
      'operationalCostPercentage': 20.0,
      'operationalCostFixed': 0.0,
      'status': status, // Always include status
    };

    final response = await _authService.apiClient.post(
      '/Workbooks',
      body: headerBody,
      includeAuth: true,
    );

    final newWorkbookId = response['id'];

    // 2. Add Ingredients
    final ingredients = sheetData['ingredients'] as List<dynamic>? ?? [];
    for (var ing in ingredients) {
      print('DEBUG - Processing ingredient for create: $ing');
      // Backend accepts both:
      // - Items with priceItemId (from database)
      // - Manual items with name, unit, price (without priceItemId)
      final body = ing['priceItemId'] != null
          ? {
              'priceItemId': ing['priceItemId'],
              'quantity': ing['amount'],
              'unit': ing['unit'] ?? 'unid', // Use unit from ingredient
              'additionalCost': 0.0,
            }
          : {
              'name': ing['name'] ?? 'Ingrediente',
              'quantity': ing['amount'] ?? 1.0,
              'unit': ing['unit'] ?? 'unid', // Use unit from ingredient
              'unitPrice': ing['unitPrice'] ?? 0.0,
              'additionalCost': 0.0,
            };

      print('DEBUG - Posting ingredient body: $body');
      await _authService.apiClient.post(
        '/Workbooks/$newWorkbookId/items',
        body: body,
        includeAuth: true,
      );
    }

    // 3. Add Extras
    final extras = sheetData['extras'] as List<dynamic>? ?? [];
    for (var ext in extras) {
      final body = ext['priceItemId'] != null
          ? {
              'priceItemId': ext['priceItemId'],
              'quantity': ext['amount'],
              'unit': 'unid',
              'additionalCost': 0.0,
            }
          : {
              'name': ext['name'] ?? 'Extra',
              'quantity': ext['amount'] ?? 1.0,
              'unit': 'unid',
              'unitPrice': ext['unitPrice'] ?? 0.0,
              'additionalCost': 0.0,
            };

      await _authService.apiClient.post(
        '/Workbooks/$newWorkbookId/items',
        body: body,
        includeAuth: true,
      );
    }

    return response;
  }

  /// Get all sheets
  Future<List<Map<String, dynamic>>> getSheets() async {
    final response = await _authService.apiClient.get(
      '/Workbooks',
      includeAuth: true,
    );

    final List<dynamic> data = (response['data'] is List)
        ? response['data']
        : [];

    // Fetch details for each workbook to populate items
    final futures = data.map(
      (wb) => _fetchWorkbookDetails(wb['id'], wb['status']),
    );
    return Future.wait(futures);
  }

  Future<Map<String, dynamic>> _fetchWorkbookDetails(
    int id,
    dynamic statusFromList,
  ) async {
    final wb = await _authService.apiClient.get(
      '/Workbooks/$id',
      includeAuth: true,
    );

    // Map to frontend structure
    return {
      'id': wb['id'].toString(),
      'name': wb['name'],
      'currency': 'Bs',
      'rationQty': 1.0, // Default
      'productQty': wb['productionUnits'],
      'salePrice': wb['targetSalePrice'],
      'margin': '${wb['profitMarginPercentage']} %',
      'status': _parseStatus(wb['status'] ?? statusFromList), // Use fallback
      'ingredients': () {
        print('DEBUG - Raw workbook data: ${wb}');
        print('DEBUG - Items from backend: ${wb['items']}');
        final items = (wb['items'] as List<dynamic>?) ?? [];
        print('DEBUG - Total items count: ${items.length}');

        final mappedItems = items.map((item) {
          print('DEBUG - Processing item: $item');
          print('DEBUG - priceItem: ${item['priceItem']}');
          print('DEBUG - priceItemId: ${item['priceItemId']}');

          return {
            'name': item['priceItem']?['product'] ?? item['name'] ?? 'Unknown',
            'amount': item['quantity'] ?? 0.0,
            'cost': item['priceItem']?['price'] ?? item['unitPrice'] ?? 0.0,
            'unitPrice':
                item['unitPrice'] ?? item['priceItem']?['price'] ?? 0.0,
            'priceItemId': item['priceItemId'],
          };
        }).toList();

        print('DEBUG - Mapped ingredients: $mappedItems');
        return mappedItems;
      }(),
      'extras': [], // TODO: Backend merges extras into items - need to separate
    };
  }

  /// Update a sheet (e.g. rename, update items)
  Future<void> updateSheet(
    dynamic id,
    Map<String, dynamic> updates, {
    List<dynamic>? ingredients,
    List<dynamic>? extras,
  }) async {
    // Fetch current to get required fields
    final current = await _authService.apiClient.get(
      '/Workbooks/$id',
      includeAuth: true,
    );

    final body = {
      'name': updates['name'] ?? current['name'],
      'productionUnits': current['productionUnits'],
      'taxPercentage': current['taxPercentage'],
      'profitMarginPercentage': current['profitMarginPercentage'],
      'targetSalePrice': current['targetSalePrice'],
      'operationalCostPercentage': current['operationalCostPercentage'],
      'operationalCostFixed': current['operationalCostFixed'],
      if (updates['status'] != null) 'status': updates['status'],
    };

    print(
      'DEBUG - Updating workbook $id with status: ${updates['status']}',
    ); // Debug log
    print('DEBUG - Full body: $body'); // Debug log

    await _authService.apiClient.put(
      '/Workbooks/$id',
      body: body,
      includeAuth: true,
    );

    // If ingredients or extras are provided, update them
    if (ingredients != null || extras != null) {
      print('DEBUG - Updating items for workbook $id');
      print('DEBUG - Ingredients to add: $ingredients');
      print('DEBUG - Extras to add: $extras');

      // First, delete all existing items
      final currentItems = current['items'] as List<dynamic>? ?? [];
      print('DEBUG - Current items to delete: ${currentItems.length}');
      for (var item in currentItems) {
        try {
          print('DEBUG - Deleting item ${item['id']}');
          await _authService.apiClient.delete(
            '/Workbooks/$id/items/${item['id']}',
            includeAuth: true,
          );
        } catch (e) {
          print('DEBUG - Error deleting item ${item['id']}: $e');
        }
      }

      // Add new ingredients
      if (ingredients != null) {
        print('DEBUG - Adding ${ingredients.length} ingredients');
        for (var ing in ingredients) {
          print('DEBUG - Ingredient data: $ing');
          if (ing['priceItemId'] != null) {
            final body = {
              'priceItemId': ing['priceItemId'],
              'quantity': ing['amount'],
              'unit': 'unid',
              'additionalCost': 0.0,
            };
            print('DEBUG - Posting ingredient: $body');
            await _authService.apiClient.post(
              '/Workbooks/$id/items',
              body: body,
              includeAuth: true,
            );
          } else {
            print('DEBUG - Skipping ingredient (no priceItemId): $ing');
          }
        }
      }

      // Add new extras
      if (extras != null) {
        print('DEBUG - Adding ${extras.length} extras');
        for (var ext in extras) {
          print('DEBUG - Extra data: $ext');
          if (ext['priceItemId'] != null) {
            final body = {
              'priceItemId': ext['priceItemId'],
              'quantity': ext['amount'],
              'unit': 'unid',
              'additionalCost': 0.0,
            };
            print('DEBUG - Posting extra: $body');
            await _authService.apiClient.post(
              '/Workbooks/$id/items',
              body: body,
              includeAuth: true,
            );
          } else {
            print('DEBUG - Skipping extra (no priceItemId): $ext');
          }
        }
      }
      print('DEBUG - Finished updating items');
    } else {
      print('DEBUG - No ingredients or extras provided to updateSheet');
    }
  }

  /// Publish a draft workbook (change status from 0 to 1)
  Future<void> publishWorkbook(String id) async {
    print('DEBUG - Publishing workbook $id'); // Debug log
    await _authService.apiClient.put(
      '/Workbooks/$id/publish',
      body: {},
      includeAuth: true,
    );
  }

  /// Delete a workbook
  Future<void> deleteSheet(String id) async {
    await _authService.apiClient.delete('/Workbooks/$id', includeAuth: true);
  }

  int _parseStatus(dynamic status) {
    print(
      'DEBUG - _parseStatus received: $status (${status.runtimeType})',
    ); // Debug log
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
