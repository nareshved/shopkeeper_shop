import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../services/profit_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_textfield.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _expensesController = TextEditingController(text: '0');

  int _currentNavIndex = 0;

  @override
  void dispose() {
    _productNameController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  void _calculateProfit() {
    if (!_formKey.currentState!.validate()) return;

    final calculation = ProfitService.calculate(
      productName: _productNameController.text.trim(),
      costPrice: double.tryParse(_costPriceController.text) ?? 0,
      sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      expenses: double.tryParse(_expensesController.text) ?? 0,
    );

    Navigator.pushNamed(context, '/result', arguments: calculation);
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
    if (index == 1) {
      Navigator.pushNamed(context, '/history');
      // Reset back to home tab after navigating
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _currentNavIndex = 0);
      });
    }
  }

  void _logout() async {
    await SupabaseService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calculate,
                      color: AppTheme.primaryGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Smart Shop',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: AppTheme.textMedium),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: _logout,
                        child: const Row(
                          children: [
                            Icon(Icons.logout, size: 20, color: AppTheme.errorRed),
                            SizedBox(width: 8),
                            Text('Sign Out'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Main Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profit Calculator',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Calculate your business margins instantly.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Product Name
                      CustomTextField(
                        label: 'Product Name',
                        hintText: 'e.g. Wireless Headphones',
                        controller: _productNameController,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter the product name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Cost & Selling Price Row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Cost Price (INR)',
                              hintText: '0.00',
                              controller: _costPriceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              prefixText: '₹ ',
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(val) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: CustomTextField(
                              label: 'Selling Price (INR)',
                              hintText: '0.00',
                              controller: _sellingPriceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              prefixText: '₹ ',
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(val) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Quantity & Expenses Row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Quantity',
                              hintText: '1',
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Required';
                                }
                                final qty = int.tryParse(val);
                                if (qty == null || qty < 1) {
                                  return 'Min. 1';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: CustomTextField(
                              label: 'Extra Expenses',
                              hintText: '0.00',
                              controller: _expensesController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              prefixText: '₹ ',
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Calculate Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _calculateProfit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor:
                                AppTheme.primaryGreen.withValues(alpha: 0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.trending_up, size: 22),
                              const SizedBox(width: 10),
                              const Text(
                                'Calculate Profit',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Pro Tip card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                AppTheme.primaryGreen.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.info_outline,
                                  color: AppTheme.primaryGreen, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pro Tip',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Remember to include shipping and packaging in 'Extra Expenses'.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation ──
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppTheme.borderColor.withValues(alpha: 0.5)),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_outlined, Icons.home, 'Home'),
                _navItem(1, Icons.history, Icons.history, 'History'),
                _navItem(2, Icons.bar_chart_outlined, Icons.bar_chart, 'Reports'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = index == _currentNavIndex;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: isActive
                ? BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  )
                : null,
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primaryGreen : AppTheme.textLight,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppTheme.primaryGreen : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
