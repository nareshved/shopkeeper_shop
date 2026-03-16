import '../models/profit_model.dart';

class ProfitService {
  /// Calculate profit from given inputs.
  ///
  /// Formula: Profit = (Selling Price − Cost Price) × Quantity − Extra Expenses
  static ProfitCalculation calculate({
    required String productName,
    required double costPrice,
    required double sellingPrice,
    required int quantity,
    required double expenses,
  }) {
    final profit = (sellingPrice - costPrice) * quantity - expenses;

    return ProfitCalculation(
      productName: productName,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      quantity: quantity,
      expenses: expenses,
      profit: profit,
      createdAt: DateTime.now(),
    );
  }

  /// Generate a smart insight message based on the calculation
  static String getInsight(ProfitCalculation calc) {
    if (!calc.isProfitable) {
      final lossPerItem =
          (calc.costPrice - calc.sellingPrice) + (calc.expenses / calc.quantity);
      return 'You are selling at a loss of ₹${lossPerItem.toStringAsFixed(0)} per item. '
          'Consider increasing the selling price or reducing expenses.';
    }

    if (calc.profitMarginPercent < 10) {
      return 'Your margins are thin at ${calc.profitMarginPercent.toStringAsFixed(1)}%. '
          'Even a small increase in selling price could significantly boost profits.';
    }

    if (calc.expenses > 0) {
      final potentialIncrease = calc.expenses * 0.25;
      final percentIncrease =
          calc.profit > 0 ? (potentialIncrease / calc.profit * 100) : 0;
      return 'Your margins are healthy. Reducing extra expenses by '
          '₹${potentialIncrease.toStringAsFixed(0)} could increase '
          'total profit by ${percentIncrease.toStringAsFixed(0)}%.';
    }

    return 'Great profit margins! You are earning '
        '₹${calc.profitPerItem.toStringAsFixed(0)} per item with '
        '${calc.profitMarginPercent.toStringAsFixed(1)}% margin.';
  }
}
