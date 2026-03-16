import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/profit_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/profit_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProfitCalculation> _allCalculations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final calculations = await SupabaseService.getHistory();
      if (mounted) {
        setState(() {
          _allCalculations = calculations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  List<ProfitCalculation> get _filteredCalculations {
    final now = DateTime.now();
    switch (_tabController.index) {
      case 1: // This Week
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartDate =
            DateTime(weekStart.year, weekStart.month, weekStart.day);
        return _allCalculations
            .where((c) =>
                c.createdAt != null && c.createdAt!.isAfter(weekStartDate))
            .toList();
      case 2: // This Month
        final monthStart = DateTime(now.year, now.month, 1);
        return _allCalculations
            .where(
                (c) => c.createdAt != null && c.createdAt!.isAfter(monthStart))
            .toList();
      default: // All
        return _allCalculations;
    }
  }

  double get _totalProfit {
    return SupabaseService.getTotalProfit(_filteredCalculations);
  }

  Future<void> _deleteCalculation(ProfitCalculation calc) async {
    if (calc.id == null) return;
    try {
      await SupabaseService.deleteCalculation(calc.id!);
      setState(() {
        _allCalculations.removeWhere((c) => c.id == calc.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${calc.productName} deleted'),
            backgroundColor: AppTheme.textMedium,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.##');
    final filtered = _filteredCalculations;

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
          'History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.textMedium),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textMedium),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _loadHistory,
                child: const Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: AppTheme.borderColor.withValues(alpha: 0.5)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryGreen,
              indicatorWeight: 3,
              labelColor: AppTheme.primaryGreen,
              unselectedLabelColor: AppTheme.textMedium,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'This Week'),
                Tab(text: 'This Month'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: AppTheme.errorRed),
                      const SizedBox(height: 12),
                      Text(_errorMessage!,
                          style: const TextStyle(color: AppTheme.textMedium)),
                      const SizedBox(height: 16),
                      TextButton(
                          onPressed: _loadHistory,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primaryGreen,
                  onRefresh: _loadHistory,
                  child: filtered.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.history,
                                        size: 64,
                                        color: AppTheme.textLight
                                            .withValues(alpha: 0.5)),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No calculations yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Your saved calculations will appear here',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            // ── Total Profit Summary ──
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryGreen,
                                    AppTheme.primaryGreen
                                        .withValues(alpha: 0.85),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen
                                        .withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _tabController.index == 0
                                            ? 'Total Profit'
                                            : _tabController.index == 1
                                                ? 'Profit This Week'
                                                : 'Profit This Month',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white
                                              .withValues(alpha: 0.85),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '₹${formatter.format(_totalProfit.abs())}',
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.trending_up,
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      size: 26,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Section Label ──
                            Text(
                              'RECENT CALCULATIONS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMedium,
                                letterSpacing: 1.5,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ── Calculation List ──
                            ...filtered.map((calc) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ProfitCard(
                                    calculation: calc,
                                    onTap: () => Navigator.pushNamed(
                                        context, '/result',
                                        arguments: calc),
                                    onDelete: () => _deleteCalculation(calc),
                                  ),
                                )),
                          ],
                        ),
                ),
    );
  }
}
