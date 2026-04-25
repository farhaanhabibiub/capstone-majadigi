import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifikasiService {
  NotifikasiService._();

  static const _seenKey = 'notif_seen_count';

  static CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('notifications');

  static Stream<QuerySnapshot<Map<String, dynamic>>> stream() =>
      _col.orderBy('createdAt', descending: true).snapshots();

  static Future<void> create({required String title, required String body}) =>
      _col.add({
        'title': title,
        'body': body,
        'createdAt': FieldValue.serverTimestamp(),
      });

  static Future<void> delete(String docId) => _col.doc(docId).delete();

  // Ambil jumlah notifikasi yang belum dilihat
  static Future<int> getUnreadCount() async {
    try {
      final snap = await _col.get();
      final total = snap.docs.length;
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getInt(_seenKey) ?? 0;
      return (total - seen).clamp(0, total);
    } catch (_) {
      return 0;
    }
  }

  // Tandai semua notifikasi sudah dilihat
  static Future<void> markAllSeen() async {
    try {
      final snap = await _col.get();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_seenKey, snap.docs.length);
    } catch (_) {}
  }
}
