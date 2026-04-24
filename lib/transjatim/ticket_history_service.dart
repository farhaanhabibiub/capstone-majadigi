import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TicketHistoryService {
  static const _key = 'transjatim_ticket_history';

  static Future<void> saveTicket(Map<String, dynamic> ticket) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.insert(0, ticket);
    if (list.length > 20) list.removeLast();
    await prefs.setString(_key, jsonEncode(list));
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
