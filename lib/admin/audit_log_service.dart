import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Audit trail untuk aksi admin — disimpan di Firestore koleksi `audit_logs`.
///
/// Tujuan: jejak forensik bila terjadi salah hapus / status berubah,
/// memenuhi kewajiban tata kelola data Pemerintah Daerah.
///
/// Skema dokumen:
///   actorUid       (string)  — uid admin yang melakukan aksi
///   actorEmail     (string)  — email admin
///   action         (string)  — kode aksi, contoh: laporan.update_status
///   targetType     (string)  — jenis target: laporan, notifikasi, ...
///   targetId       (string)  — id dokumen yang dipengaruhi
///   details        (map)     — data tambahan (sebelum/sesudah, dll)
///   createdAt      (server timestamp)
///   createdAtMs    (number)  — untuk sort cepat di klien
class AuditLogService {
  AuditLogService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String collection = 'audit_logs';

  // Action codes
  static const String actionUpdateLaporanStatus = 'laporan.update_status';
  static const String actionDeleteNotifikasi = 'notifikasi.delete';
  static const String actionCreateNotifikasi = 'notifikasi.create';

  /// Catat satu entri audit. Tidak melempar error agar tidak mengganggu
  /// alur utama UI bila Firestore sedang offline.
  static Future<void> record({
    required String action,
    required String targetType,
    required String targetId,
    Map<String, dynamic> details = const {},
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      await _db.collection(collection).add({
        'actorUid': user.uid,
        'actorEmail': user.email,
        'action': action,
        'targetType': targetType,
        'targetId': targetId,
        'details': details,
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtMs': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {
      // Sengaja diabaikan — audit gagal tidak boleh memblokir aksi admin.
    }
  }

  /// Stream daftar log terbaru (untuk halaman audit log).
  static Stream<List<AuditLogEntry>> stream({int limit = 100}) {
    return _db
        .collection(collection)
        .orderBy('createdAtMs', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(AuditLogEntry.fromDoc).toList());
  }
}

class AuditLogEntry {
  final String id;
  final String? actorEmail;
  final String action;
  final String targetType;
  final String targetId;
  final Map<String, dynamic> details;
  final DateTime? createdAt;

  const AuditLogEntry({
    required this.id,
    required this.actorEmail,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.details,
    required this.createdAt,
  });

  factory AuditLogEntry.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    final ms = data['createdAtMs'] as int?;
    return AuditLogEntry(
      id: d.id,
      actorEmail: data['actorEmail'] as String?,
      action: (data['action'] as String?) ?? '-',
      targetType: (data['targetType'] as String?) ?? '-',
      targetId: (data['targetId'] as String?) ?? '-',
      details:
          (data['details'] as Map?)?.cast<String, dynamic>() ?? const {},
      createdAt: ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null,
    );
  }

  String get actionLabel => switch (action) {
        AuditLogService.actionUpdateLaporanStatus => 'Update Status Laporan',
        AuditLogService.actionDeleteNotifikasi => 'Hapus Notifikasi',
        AuditLogService.actionCreateNotifikasi => 'Kirim Notifikasi',
        _ => action,
      };
}
