class PriceDatabase {
  final int id;
  final String name;
  final DateTime uploadDate;
  final int itemCount;
  final List<PriceItem> items;

  PriceDatabase({
    required this.id,
    required this.name,
    required this.uploadDate,
    required this.itemCount,
    required this.items,
  });

  factory PriceDatabase.fromJson(Map<String, dynamic> json) {
    return PriceDatabase(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      uploadDate: DateTime.tryParse(json['uploadDate'] ?? '') ?? DateTime.now(),
      itemCount: json['itemCount'] ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => PriceItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PriceItem {
  final int id;
  final int priceDatabaseId;
  final String product;
  final double price;
  final String? unit;

  PriceItem({
    required this.id,
    required this.priceDatabaseId,
    required this.product,
    required this.price,
    this.unit,
  });

  factory PriceItem.fromJson(Map<String, dynamic> json) {
    return PriceItem(
      id: json['id'] ?? 0,
      priceDatabaseId: json['priceDatabaseId'] ?? 0,
      product: json['product'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'priceDatabaseId': priceDatabaseId,
      'product': product,
      'price': price,
      'unit': unit,
    };
  }
}
