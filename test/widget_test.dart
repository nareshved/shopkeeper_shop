import 'package:flutter_test/flutter_test.dart';
import 'package:shopkeeper_shop/models/profit_model.dart';
import 'package:shopkeeper_shop/services/profit_service.dart';

void main() {
  group('ProfitService', () {
    test('calculates profit correctly', () {
      final result = ProfitService.calculate(
        productName: 'Biscuit',
        costPrice: 50,
        sellingPrice: 60,
        quantity: 10,
        expenses: 20,
      );

      expect(result.profit, equals(80.0));
      expect(result.profitPerItem, equals(10.0));
      expect(result.isProfitable, isTrue);
    });

    test('detects loss correctly', () {
      final result = ProfitService.calculate(
        productName: 'Soap',
        costPrice: 30,
        sellingPrice: 25,
        quantity: 5,
        expenses: 10,
      );

      expect(result.profit, equals(-35.0));
      expect(result.isProfitable, isFalse);
    });

    test('handles zero expenses', () {
      final result = ProfitService.calculate(
        productName: 'Tea',
        costPrice: 10,
        sellingPrice: 15,
        quantity: 20,
        expenses: 0,
      );

      expect(result.profit, equals(100.0));
      expect(result.isProfitable, isTrue);
    });
  });

  group('ProfitCalculation model', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        'id': 'test-id',
        'user_id': 'user-123',
        'product_name': 'Biscuit',
        'cost_price': 50.0,
        'selling_price': 60.0,
        'quantity': 10,
        'expenses': 20.0,
        'profit': 80.0,
        'created_at': '2026-03-16T12:00:00.000Z',
      };

      final model = ProfitCalculation.fromJson(json);
      expect(model.productName, equals('Biscuit'));
      expect(model.profit, equals(80.0));
      expect(model.isProfitable, isTrue);
      expect(model.formattedProfit, contains('80'));

      final output = model.toJson();
      expect(output['product_name'], equals('Biscuit'));
      expect(output['profit'], equals(80.0));
    });

    test('toShareText generates valid share text', () {
      final calc = ProfitCalculation(
        productName: 'Biscuit',
        costPrice: 50,
        sellingPrice: 60,
        quantity: 10,
        expenses: 20,
        profit: 80,
      );

      final text = calc.toShareText();
      expect(text, contains('Biscuit'));
      expect(text, contains('Profit'));
      expect(text, contains('Smart Shop'));
    });

    test('profitMarginPercent calculation', () {
      final calc = ProfitCalculation(
        productName: 'Test',
        costPrice: 50,
        sellingPrice: 100,
        quantity: 1,
        expenses: 0,
        profit: 50,
      );

      expect(calc.profitMarginPercent, equals(50.0));
    });
  });
}
