import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_retry.dart';
import '../widgets/skeleton_loader.dart';
import 'notifikasi_service.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  static const _pageSize = 20;

  final _scrollCtrl = ScrollController();
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];

  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  Object? _error;
  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  @override
  void initState() {
    super.initState();
    NotifikasiService.markAllSeen();
    _scrollCtrl.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || !_hasMore) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _initialLoading = true;
      _error = null;
      _docs.clear();
      _cursor = null;
      _hasMore = true;
    });
    try {
      final snap = await NotifikasiService.page(limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _docs.addAll(snap.docs);
        _cursor = snap.docs.isNotEmpty ? snap.docs.last : null;
        _hasMore = snap.docs.length == _pageSize;
        _initialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _initialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_cursor == null) {
      setState(() => _hasMore = false);
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final snap = await NotifikasiService.page(
        limit: _pageSize,
        startAfter: _cursor,
      );
      if (!mounted) return;
      setState(() {
        _docs.addAll(snap.docs);
        if (snap.docs.isNotEmpty) _cursor = snap.docs.last;
        _hasMore = snap.docs.length == _pageSize;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        _hasMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: ${ErrorRetry.fromException(e)}')),
      );
    }
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate().toLocal();
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$d/$mo/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_initialLoading) return SkeletonLoader.list();

    if (_error != null) {
      return ErrorRetry(
        title: 'Gagal memuat notifikasi',
        subtitle: ErrorRetry.fromException(_error!),
        onRetry: _loadFirstPage,
      );
    }

    if (_docs.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'Belum ada notifikasi',
        subtitle:
            'Pemberitahuan layanan & info penting akan muncul di sini.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: EdgeInsets.zero,
        itemCount: _docs.length + 1,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          thickness: 1,
          color: Color.fromRGBO(240, 240, 240, 1),
        ),
        itemBuilder: (context, index) {
          if (index == _docs.length) return _buildFooter();
          final data = _docs[index].data();
          final title = data['title'] as String? ?? '';
          final body = data['body'] as String? ?? '';
          final ts = data['createdAt'] as Timestamp?;
          return _buildItem(title: title, body: body, time: _formatTime(ts));
        },
      ),
    );
  }

  Widget _buildFooter() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }
    if (!_hasMore && _docs.length > _pageSize) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(
            'Sudah sampai bawah',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildItem({
    required String title,
    required String body,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (time.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
