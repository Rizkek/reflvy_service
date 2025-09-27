import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

class StatisticsService {
  static const String _cacheKeyToday = 'statistics_today_cache';
  static const String _cacheKey7Days = 'statistics_7days_cache';
  static const String _cacheStamp7Days = 'statistics_7days_cached_date';

  // Returns cached JSON if exists; otherwise null
  static Future<Map<String, dynamic>?> getCachedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKeyToday);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Force fetch from API using Bearer token
  static Future<Map<String, dynamic>?> fetchToday() async {
    final token = await SecureStorageService.getToken();
    if (token == null) return null;

    final uri = Uri.parse(ApiUrls.statistics(period: 'today'));
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeyToday, jsonEncode(decoded));
      return decoded;
    }

    return null;
  }

  // Get statistics preferring cache; set forceRefresh to bypass cache.
  static Future<Map<String, dynamic>?> getToday({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await getCachedToday();
      if (cached != null) return cached;
    }
    return fetchToday();
  }

  // 7 days helpers
  static Future<Map<String, dynamic>?> getCached7Days() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey7Days);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetch7Days() async {
    final token = await SecureStorageService.getToken();
    if (token == null) return null;
    final uri = Uri.parse(ApiUrls.statistics(period: '7days'));
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey7Days, jsonEncode(decoded));
      final todayStamp = _todayStamp();
      await prefs.setString(_cacheStamp7Days, todayStamp);
      return decoded;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> get7Days() async {
    final prefs = await SharedPreferences.getInstance();
    final stamp = prefs.getString(_cacheStamp7Days);
    final today = _todayStamp();
    if (stamp == today) {
      final cached = await getCached7Days();
      if (cached != null) return cached;
    }
    return fetch7Days();
  }

  static String _todayStamp() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}$mm$dd';
  }
}
