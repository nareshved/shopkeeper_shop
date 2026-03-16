import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../models/profit_model.dart';
import '../../services/profit_service.dart';
import '../../services/supabase_service.dart';

class ResultScreen extends StatefulWidget {
  final ProfitCalculation calculation;

  const ResultScreen({super.key, required this.calculation});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  bool _isSaving = false;
  bool _isSaved = false;

  ProfitCalculation get calc => widget.calculation;
  final _formatter = NumberFormat('#,##0.##');

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _saveCalculation() async {
    if (_isSaved) return;
    setState(() => _isSaving = true);
    try {
      await SupabaseService.saveCalculation(calc);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Calculation saved successfully!'),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _shareResult() {
    SharePlus.instance.share(ShareParams(text: calc.toShareText()));
  }

  @override
  Widget build(BuildContext context) {
    final insight = ProfitService.getInsight(calc);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calculation Result',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppTheme.borderColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ── Status Icon ──
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: calc.isProfitable
                      ? AppTheme.primaryGreen.withValues(alpha: 0.15)
                      : AppTheme.errorRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  calc.isProfitable ? Icons.trending_up : Icons.trending_down,
                  size: 32,
                  color: calc.isProfitable
                      ? AppTheme.primaryGreen
                      : AppTheme.errorRed,
                ),
              ),
              const SizedBox(height: 16),

              // ── Title ──
              Text(
                calc.isProfitable ? 'Great News!' : 'Attention!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                calc.isProfitable ? 'You made profit' : 'You are selling at a loss',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: calc.isProfitable
                      ? AppTheme.primaryGreen
                      : AppTheme.errorRed,
                ),
              ),

              const SizedBox(height: 28),

              // ── Profit Cards Row ──
              Row(
                children: [
                  // Per Item Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.borderColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profit per item',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${_formatter.format(calc.profitPerItem)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                calc.isProfitable
                                    ? Icons.north_east
                                    : Icons.south_east,
                                size: 14,
                                color: calc.isProfitable
                                    ? AppTheme.primaryGreen
                                    : AppTheme.errorRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${calc.profitMarginPercent >= 0 ? '+' : ''}${calc.profitMarginPercent.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: calc.isProfitable
                                      ? AppTheme.primaryGreen
                                      : AppTheme.errorRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Total Profit Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: calc.isProfitable
                              ? [
                                  AppTheme.primaryGreen,
                                  AppTheme.primaryGreen.withValues(alpha: 0.85),
                                ]
                              : [
                                  AppTheme.errorRed,
                                  AppTheme.errorRed.withValues(alpha: 0.85),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            calc.isProfitable ? 'Total Profit' : 'Total Loss',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${_formatter.format(calc.profit.abs())}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Net Earnings',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Detailed Breakdown ──
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DETAILED BREAKDOWN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMedium,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.borderColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    _breakdownRow('Cost Price (per item)',
                        '₹${_formatter.format(calc.costPrice)}', false),
                    _divider(),
                    _breakdownRow('Selling Price (per item)',
                        '₹${_formatter.format(calc.sellingPrice)}', false),
                    _divider(),
                    _breakdownRow('Quantity', '${calc.quantity}', false),
                    _divider(),
                    _breakdownRow(
                      'Extra Expenses',
                      '-₹${_formatter.format(calc.expenses)}',
                      true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Insights Card ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.borderColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bar_chart,
                          color: AppTheme.primaryGreen, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Calculation Insights',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insight,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMedium,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Action Buttons ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveCalculation,
                  icon: Icon(
                    _isSaved ? Icons.check : Icons.save_outlined,
                    size: 20,
                  ),
                  label: Text(
                    _isSaved ? 'Saved!' : 'Save Calculation',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSaved
                        ? AppTheme.primaryGreen.withValues(alpha: 0.7)
                        : AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share_outlined, size: 20),
                  label: const Text(
                    'Share Result',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textDark,
                    side: const BorderSide(color: AppTheme.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, String value, bool isExpense) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w500),
              ),
              if (isExpense) ...[
                const SizedBox(width: 4),
                Icon(Icons.info_outline,
                    size: 14, color: AppTheme.textLight),
              ],
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isExpense ? AppTheme.errorRed : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 18,
      endIndent: 18,
      color: AppTheme.borderColor.withValues(alpha: 0.5),
    );
  }
}
