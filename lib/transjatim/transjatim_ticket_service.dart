import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/transjatim_model.dart';

/// Status sebuah tiket Transjatim.
enum TicketStatus { active, used }

/// Snapshot ringkas status tiket dari Firestore.
class TicketStatusSnapshot {
  final String orderId;
  final TicketStatus status;
  final DateTime? usedAt;
  final String? usedByUid;

  const TicketStatusSnapshot({
    required this.orderId,
    required this.status,
    this.usedAt,
    this.usedByUid,
  });

  bool get isUsed => status == TicketStatus.used;
}

/// Wrapper Firestore untuk tiket Transjatim. Tiket disimpan di koleksi
/// `transjatim_tickets/{orderId}` agar dapat dipindai oleh admin/petugas
/// dari device lain dan ditandai sebagai sudah digunakan (one-shot).
class TransjatimTicketService {
  TransjatimTicketService._();

  static const String _collectionName = 'transjatim_tickets';

  static CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection(_collectionName);

  /// Simpan tiket baru ke Firestore dengan status `active`. Dipanggil dari
  /// PaymentPage setelah user bayar.
  static Future<void> save(TicketOrder order, String uid) async {
    await _col.doc(order.orderId).set({
      'orderId': order.orderId,
      'uid': uid,
      'routeId': order.route.id,
      'routeTitle': order.route.title,
      'city': order.route.city,
      'fromStop': order.fromStop,
      'toStop': order.toStop,
      'fromIndex': order.fromIndex,
      'toIndex': order.toIndex,
      'ticketClass': order.ticketClass.label,
      'passengerCount': order.passengerCount,
      'paymentMethod': order.paymentMethod,
      'bookingTime': order.bookingTime.toIso8601String(),
      'totalPrice': order.totalPrice,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Ambil status terbaru tiket. Return null bila orderId tidak ada
  /// (mis. QR yang dipindai bukan tiket Majadigi).
  static Future<TicketStatusSnapshot?> getStatus(String orderId) async {
    final doc = await _col.doc(orderId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return TicketStatusSnapshot(
      orderId: orderId,
      status: _parseStatus(data['status'] as String?),
      usedAt: _parseTime(data['usedAt']),
      usedByUid: data['usedByUid'] as String?,
    );
  }

  /// Ambil dokumen tiket lengkap (untuk panel admin scanner).
  static Future<Map<String, dynamic>?> fetch(String orderId) async {
    final doc = await _col.doc(orderId).get();
    return doc.exists ? doc.data() : null;
  }

  /// Tandai tiket sebagai sudah digunakan (idempotent: gagal bila tiket
  /// belum ada atau sudah pernah ditandai used). Pakai transaction supaya
  /// race-condition antar admin scan terjaga.
  ///
  /// Mengembalikan [TicketScanOutcome] yang menjelaskan hasilnya.
  static Future<TicketScanOutcome> markUsed({
    required String orderId,
    required String adminUid,
  }) async {
    final docRef = _col.doc(orderId);
    try {
      return await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) {
          return const TicketScanOutcome(result: TicketScanResult.notFound);
        }
        final data = snap.data()!;
        final status = _parseStatus(data['status'] as String?);
        if (status == TicketStatus.used) {
          return TicketScanOutcome(
            result: TicketScanResult.alreadyUsed,
            data: data,
          );
        }
        tx.update(docRef, {
          'status': 'used',
          'usedAt': FieldValue.serverTimestamp(),
          'usedByUid': adminUid,
        });
        return TicketScanOutcome(
          result: TicketScanResult.success,
          data: data,
        );
      });
    } catch (e) {
      return TicketScanOutcome(result: TicketScanResult.error, error: e);
    }
  }

  /// Ambil semua tiket milik [uid], terurut paling baru duluan.
  /// Jangan pakai .orderBy() di Firestore tanpa index — kita sort di klien.
  static Future<List<Map<String, dynamic>>> userTickets(String uid) async {
    final snap = await _col.where('uid', isEqualTo: uid).get();
    final list = snap.docs.map((d) => d.data()).toList();
    list.sort((a, b) {
      final aTime = a['bookingTime'] as String? ?? '';
      final bTime = b['bookingTime'] as String? ?? '';
      return bTime.compareTo(aTime);
    });
    return list;
  }

  static TicketStatus _parseStatus(String? raw) {
    return raw == 'used' ? TicketStatus.used : TicketStatus.active;
  }

  static DateTime? _parseTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}

enum TicketScanResult { success, alreadyUsed, notFound, error }

class TicketScanOutcome {
  final TicketScanResult result;
  final Map<String, dynamic>? data;
  final Object? error;

  const TicketScanOutcome({required this.result, this.data, this.error});
}
