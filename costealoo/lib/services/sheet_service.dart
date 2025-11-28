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

    final headerBody = {
      'name': sheetData['name'],
      'productionUnits': sheetData['productQty'] ?? 1.0,
      'taxPercentage': 16.0,
      'profitMarginPercentage': margin,
      'targetSalePrice': sheetData['salePrice'],
      'operationalCostPercentage': 20.0,
      'operationalCostFixed': 0.0,
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
      if (ing['priceItemId'] != null) {
        await _authService.apiClient.post(
          '/Workbooks/$newWorkbookId/items',
          body: {
            'priceItemId': ing['priceItemId'],
            'quantity': ing['amount'],
            'unit': 'unid', // Default unit
            'additionalCost': 0.0,
          },
          includeAuth: true,
        );
      }
    }

    // 3. Add Extras
    final extras = sheetData['extras'] as List<dynamic>? ?? [];
    for (var ext in extras) {
      if (ext['priceItemId'] != null) {
        await _authService.apiClient.post(
          '/Workbooks/$newWorkbookId/items',
          body: {
            'priceItemId': ext['priceItemId'],
            'quantity': ext['amount'],
            'unit': 'unid',
            'additionalCost': 0.0,
          },
          includeAuth: true,
        );
      }
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
    final futures = data.map((wb) => _fetchWorkbookDetails(wb['id']));
    return Future.wait(futures);
  }

  Future<Map<String, dynamic>> _fetchWorkbookDetails(int id) async {
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
      'ingredients':
          (wb['items'] as List<dynamic>?)?.map((item) {
            return {
              'name': item['priceItem']?['product'] ?? 'Unknown',
              'amount': item['quantity'],
              'cost': item['priceItem']?['price'] ?? 0.0,
              'priceItemId': item['priceItemId'],
            };
          }).toList() ??
          [],
      'extras': [], // Extras are merged into items in backend
    };
  }

  /// Update a sheet (e.g. rename)
  Future<void> updateSheet(dynamic id, Map<String, dynamic> updates) async {
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
    };

    await _authService.apiClient.put(
      '/Workbooks/$id',
      body: body,
      includeAuth: true,
    );
  }
}
