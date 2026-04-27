import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_loader.dart';
import 'audit_log_service.dart';

class AuditLogPage extends StatelessWidget {
  const AuditLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceOf(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: AppTheme.textPrimaryOf(context)),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Audit Log',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AuditLogEntry>>(
        stream: AuditLogService.stream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return SkeletonLoader.list(itemCount: 6);
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat audit log.\n${snap.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ),
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.history_rounded,
              title: 'Belum ada aktivitas',
              subtitle:
                  'Setiap aksi admin (update status, kirim/hapus notifikasi)\nakan tercatat di sini.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _AuditCard(entry: items[i]),
          );
        },
      ),
    );
  }
}

class _AuditCard extends StatelessWidget {
  final AuditLogEntry entry;
  const _AuditCard({required this.entry});

  IconData get _icon => switch (entry.action) {
        AuditLogService.actionUpdateLaporanStatus => Icons.task_alt_rounded,
        AuditLogService.actionDeleteNotifikasi => Icons.delete_outline_rounded,
        AuditLogService.actionCreateNotifikasi => Icons.send_rounded,
        _ => Icons.bolt_rounded,
      };

  Color get _color => switch (entry.action) {
        AuditLogService.actionDeleteNotifikasi => AppTheme.danger,
        AuditLogService.actionCreateNotifikasi => AppTheme.success,
        _ => AppTheme.primary,
      };

  String get _summary {
    final d = entry.details;
    return switch (entry.action) {
      AuditLogService.actionUpdateLaporanStatus =>
        '${d['tiketId'] ?? entry.targetId}: ${d['from'] ?? '-'} → ${d['to'] ?? '-'}',
      AuditLogService.actionCreateNotifikasi => (d['title'] as String?) ?? '-',
      AuditLogService.actionDeleteNotifikasi => (d['title'] as String?) ?? entry.targetId,
      _ => entry.targetId,
    };
  }

  String _formatTime(BuildContext context) {
    final t = entry.createdAt;
    if (t == null) return '-';
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(t);
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.actionLabel,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 12, color: textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entry.actorEmail ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.schedule_rounded,
                        size: 12, color: textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(context),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
