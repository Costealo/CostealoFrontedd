import 'database_item.dart';

class Workbook {
  final int id;
  final String name;
  final double productionUnits;
  final double taxPercentage;
  final double profitMarginPercentage;
  final double? targetSalePrice;
  final double operationalCostPercentage;
  final double operationalCostFixed;
  final List<WorkbookItem> items;

  Workbook({
    required this.id,
    required this.name,
    required this.productionUnits,
    required this.taxPercentage,
    required this.profitMarginPercentage,
    this.targetSalePrice,
    required this.operationalCostPercentage,
    required this.operationalCostFixed,
    required this.items,
  });

  factory Workbook.fromJson(Map<String, dynamic> json) {
    return Workbook(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      productionUnits: (json['productionUnits'] ?? 0).toDouble(),
      taxPercentage: (json['taxPercentage'] ?? 0).toDouble(),
      profitMarginPercentage: (json['profitMarginPercentage'] ?? 0).toDouble(),
      targetSalePrice: json['targetSalePrice'] != null
          ? (json['targetSalePrice']).toDouble()
          : null,
      operationalCostPercentage: (json['operationalCostPercentage'] ?? 0)
          .toDouble(),
      operationalCostFixed: (json['operationalCostFixed'] ?? 0).toDouble(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => WorkbookItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class WorkbookItem {
  final int id;
  final int workbookId;
  final int priceItemId;
  final double quantity;
  final String unit;
  final double additionalCost;
  final PriceItem? priceItem;

  WorkbookItem({
    required this.id,
    required this.workbookId,
    required this.priceItemId,
    required this.quantity,
    required this.unit,
    required this.additionalCost,
    this.priceItem,
  });

  factory WorkbookItem.fromJson(Map<String, dynamic> json) {
    return WorkbookItem(
      id: json['id'] ?? 0,
      workbookId: json['workbookId'] ?? 0,
      priceItemId: json['priceItemId'] ?? 0,
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      additionalCost: (json['additionalCost'] ?? 0).toDouble(),
      priceItem: json['priceItem'] != null
          ? PriceItem.fromJson(json['priceItem'])
          : null,
    );
  }
}
