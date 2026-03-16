import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/profit_model.dart';

class ProfitCard extends StatelessWidget {
  final ProfitCalculation calculation;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProfitCard({
    super.key,
    required this.calculation,
    this.onTap,
    this.onDelete,
  });

  IconData _getProductIcon() {
    final name = calculation.productName.toLowerCase();
    if (name.contains('biscuit') || name.contains('food') || name.contains('snack')) {
      return Icons.inventory_2_outlined;
    }
    if (name.contains('soap') || name.contains('wash') || name.contains('clean')) {
      return Icons.clean_hands_outlined;
    }
    if (name.contains('oil') || name.contains('cook')) {
      return Icons.local_dining_outlined;
    }
    if (name.contains('flour') || name.contains('wheat') || name.contains('rice')) {
      return Icons.restaurant_outlined;
    }
    if (name.contains('milk') || name.contains('dairy')) {
      return Icons.icecream_outlined;
    }
    if (name.contains('tea') || name.contains('coffee') || name.contains('drink')) {
      return Icons.local_cafe_outlined;
    }
    return Icons.shopping_bag_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(calculation.id ?? calculation.productName),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getProductIcon(),
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      calculation.formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      calculation.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${calculation.isProfitable ? 'Profit' : 'Loss'}: ${calculation.formattedProfit}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: calculation.isProfitable
                            ? AppTheme.profitGreen
                            : AppTheme.lossRed,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right,
                color: AppTheme.textLight,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
