import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MajaAiHistoryService {
  MajaAiHistoryService._();

  static CollectionReference<Map<String, dynamic>>? _userChats() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('majaAiChats');
  }

  static Future<List<StoredMessage>> loadAll() async {
    final col = _userChats();
    if (col == null) return [];
    try {
      final snap = await col.orderBy('createdAt').get();
      return snap.docs
          .map((d) => StoredMessage.fromMap(d.id, d.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<String?> add({required String text, required bool isUser}) async {
    final col = _userChats();
    if (col == null) return null;
    try {
      final ref = await col.add({
        'text': text,
        'isUser': isUser,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (_) {
      return null;
    }
  }

  static Future<void> update(String docId, String text) async {
    final col = _userChats();
    if (col == null) return;
    try {
      await col.doc(docId).update({'text': text});
    } catch (_) {}
  }

  static Future<void> delete(String docId) async {
    final col = _userChats();
    if (col == null) return;
    try {
      await col.doc(docId).delete();
    } catch (_) {}
  }

  static Future<void> clearAll() async {
    final col = _userChats();
    if (col == null) return;
    try {
      final snap = await col.get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {}
  }
}

class StoredMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime? createdAt;

  const StoredMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.createdAt,
  });

  factory StoredMessage.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    return StoredMessage(
      id: id,
      text: data['text'] as String? ?? '',
      isUser: data['isUser'] as bool? ?? false,
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
