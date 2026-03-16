import 'package:intl/intl.dart';

class ProfitCalculation {
  final String? id;
  final String? userId;
  final String productName;
  final double costPrice;
  final double sellingPrice;
  final int quantity;
  final double expenses;
  final double profit;
  final DateTime? createdAt;

  ProfitCalculation({
    this.id,
    this.userId,
    required this.productName,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.expenses,
    required this.profit,
    this.createdAt,
  });

  /// Profit per single item (before total expenses)
  double get profitPerItem => sellingPrice - costPrice;

  /// Total revenue from all items
  double get totalRevenue => sellingPrice * quantity;

  /// Total cost including expenses
  double get totalCost => (costPrice * quantity) + expenses;

  /// Profit margin percentage
  double get profitMarginPercent {
    if (totalRevenue == 0) return 0;
    return (profit / totalRevenue) * 100;
  }

  /// Whether this is a profitable sale
  bool get isProfitable => profit > 0;

  /// Formatted date string
  String get formattedDate {
    if (createdAt == null) return '';
    return DateFormat('dd MMM').format(createdAt!);
  }

  /// Formatted profit with ₹ symbol
  String get formattedProfit {
    final formatter = NumberFormat('#,##0.##');
    return '₹${formatter.format(profit.abs())}';
  }

  factory ProfitCalculation.fromJson(Map<String, dynamic> json) {
    return ProfitCalculation(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      productName: json['product_name'] as String,
      costPrice: (json['cost_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      expenses: (json['expenses'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'product_name': productName,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'quantity': quantity,
      'expenses': expenses,
      'profit': profit,
    };
  }

  /// Generate shareable text for WhatsApp / messages
  String toShareText() {
    final formatter = NumberFormat('#,##0.##');
    return '''📊 Profit Calculation — Smart Shop

🏷️ Product: $productName
💰 Cost Price: ₹${formatter.format(costPrice)}
💵 Selling Price: ₹${formatter.format(sellingPrice)}
📦 Quantity: $quantity
📋 Extra Expenses: ₹${formatter.format(expenses)}

${isProfitable ? '✅' : '❌'} ${isProfitable ? 'Profit' : 'Loss'}: $formattedProfit
📈 Margin: ${profitMarginPercent.toStringAsFixed(1)}%

Calculated with Smart Shop Profit Calculator 🧮''';
  }
}
