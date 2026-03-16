import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';
import '../models/profit_model.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ─── Authentication ────────────────────────────────────────

  /// Current authenticated user (null if not logged in)
  static User? get currentUser => _client.auth.currentUser;

  /// Whether a user is currently signed in
  static bool get isLoggedIn => currentUser != null;

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── Profit History CRUD ───────────────────────────────────

  /// Save a profit calculation to the database
  static Future<void> saveCalculation(ProfitCalculation calculation) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final data = calculation.toJson();
    data['user_id'] = userId;

    await _client.from(AppConstants.profitHistoryTable).insert(data);
  }

  /// Get all calculations for the current user, ordered by most recent
  static Future<List<ProfitCalculation>> getHistory() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from(AppConstants.profitHistoryTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProfitCalculation.fromJson(json))
        .toList();
  }

  /// Get calculations filtered by date range
  static Future<List<ProfitCalculation>> getHistoryByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from(AppConstants.profitHistoryTable)
        .select()
        .eq('user_id', userId)
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String())
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProfitCalculation.fromJson(json))
        .toList();
  }

  /// Delete a calculation by ID
  static Future<void> deleteCalculation(String id) async {
    await _client.from(AppConstants.profitHistoryTable).delete().eq('id', id);
  }

  /// Get total profit for a given list of calculations
  static double getTotalProfit(List<ProfitCalculation> calculations) {
    return calculations.fold(0.0, (sum, calc) => sum + calc.profit);
  }
}
