import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../theme/app_theme.dart';
import 'feature_usage_service.dart';
import 'gemini_service.dart';
import 'maja_ai_history_service.dart';

class MajaAiChatPage extends StatefulWidget {
  const MajaAiChatPage({super.key});

  @override
  State<MajaAiChatPage> createState() => _MajaAiChatPageState();
}

class _MajaAiChatPageState extends State<MajaAiChatPage> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];

  ChatSession? _chat;
  StreamSubscription<GenerateContentResponse>? _streamSub;

  String _userName = '';
  String _photoUrl = '';
  bool _isLoadingUser = true;
  bool _isLoadingHistory = true;
  bool _isResponding = false;

  // ── Suggestion dinamis ────────────────────────────────────────────────────
  // Diisi dari FeatureUsageService; fallback ke _kDefaultSuggestions.
  List<String> _suggestions = const _DefaultSuggestionsList();

  // ── Rate limiter sliding window ───────────────────────────────────────────
  // Maks _kMaxPerWindow pesan per _kRateWindow detik.
  static const int _kMaxPerWindow = 8;
  static const Duration _kRateWindow = Duration(seconds: 60);
  final Queue<DateTime> _sendTimestamps = Queue<DateTime>();

  @override
  void initState() {
    super.initState();
    _chat = GeminiService.startChat();
    _loadUser();
    _loadHistory();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final top = await FeatureUsageService.topFeatures(limit: 6);
    if (!mounted) return;
    final dynamic_ = <String>[];
    for (final id in top) {
      final list = _kSuggestionsByFeature[id];
      if (list == null) continue;
      for (final s in list) {
        if (!dynamic_.contains(s)) dynamic_.add(s);
        if (dynamic_.length >= 6) break;
      }
      if (dynamic_.length >= 6) break;
    }
    if (dynamic_.isEmpty) return;
    setState(() => _suggestions = dynamic_);
  }

  Future<void> _loadHistory() async {
    final stored = await MajaAiHistoryService.loadAll();
    if (!mounted) return;
    final history = stored
        .where((m) => m.text.trim().isNotEmpty)
        .map((m) => m.isUser
            ? Content.text(m.text)
            : Content.model([TextPart(m.text)]))
        .toList();
    setState(() {
      _messages
        ..clear()
        ..addAll(stored.map((m) => _ChatMessage(
              text: m.text,
              isUser: m.isUser,
              docId: m.id,
            )));
      _chat = GeminiService.startChat(history: history);
      _isLoadingHistory = false;
    });
    if (_messages.isNotEmpty) _scrollToBottom();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _userName = (user?.displayName?.isNotEmpty == true)
          ? user!.displayName!
          : 'Pengguna';
      _photoUrl = user?.photoURL ?? '';
      _isLoadingUser = false;
    });
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Riwayat?',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: const Text(
          'Semua percakapan dengan Maja AI akan dihapus permanen dari akun Anda.',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    _streamSub?.cancel();
    await MajaAiHistoryService.clearAll();
    if (!mounted) return;
    setState(() {
      _messages.clear();
      _chat = GeminiService.startChat();
      _isResponding = false;
    });
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 11) return 'Selamat Pagi';
    if (h >= 11 && h < 15) return 'Selamat Siang';
    if (h >= 15 && h < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  // ── Kirim pesan ────────────────────────────────────────────────────────────

  /// Mengembalikan sisa detik sampai user boleh mengirim lagi.
  /// 0 berarti tidak diblokir.
  int _rateLimitWaitSeconds() {
    final now = DateTime.now();
    while (_sendTimestamps.isNotEmpty &&
        now.difference(_sendTimestamps.first) > _kRateWindow) {
      _sendTimestamps.removeFirst();
    }
    if (_sendTimestamps.length < _kMaxPerWindow) return 0;
    final oldest = _sendTimestamps.first;
    final wait = _kRateWindow - now.difference(oldest);
    return wait.inSeconds.clamp(1, _kRateWindow.inSeconds);
  }

  void _send() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _isResponding) return;
    final chat = _chat;
    if (chat == null) return;

    final wait = _rateLimitWaitSeconds();
    if (wait > 0) {
      _showSnack(
        'Terlalu cepat. Tunggu $wait detik sebelum mengirim lagi.',
        isError: true,
      );
      return;
    }
    _sendTimestamps.add(DateTime.now());

    _textCtrl.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(const _ChatMessage(text: '', isUser: false, isLoading: true));
      _isResponding = true;
    });
    _scrollToBottom();

    final userIndex = _messages.length - 2;
    MajaAiHistoryService.add(text: text, isUser: true).then((id) {
      if (!mounted || id == null) return;
      if (userIndex < _messages.length && _messages[userIndex].isUser) {
        _messages[userIndex] = _messages[userIndex].copyWith(docId: id);
      }
    });

    String accumulated = '';
    bool firstChunk = true;

    final stream = chat.sendMessageStream(Content.text(text));

    _streamSub = stream.listen(
      (chunk) {
        if (!mounted) return;
        accumulated += chunk.text ?? '';
        setState(() {
          if (firstChunk) {
            _messages.removeLast();
            _messages.add(_ChatMessage(
              text: accumulated,
              isUser: false,
              isLoading: true,
            ));
            firstChunk = false;
          } else {
            _messages[_messages.length - 1] = _ChatMessage(
              text: accumulated,
              isUser: false,
              isLoading: true,
              docId: _messages.last.docId,
            );
          }
        });
        _scrollToBottom();
      },
      onDone: () async {
        if (!mounted) return;
        final finalText = accumulated.isEmpty
            ? 'Maaf, tidak ada respons. Coba lagi ya! 😊'
            : accumulated;
        setState(() {
          if (_messages.isNotEmpty) {
            _messages[_messages.length - 1] = _ChatMessage(
              text: finalText,
              isUser: false,
              docId: _messages.last.docId,
            );
          }
          _isResponding = false;
        });
        final id = await MajaAiHistoryService.add(text: finalText, isUser: false);
        if (!mounted || id == null) return;
        final last = _messages.length - 1;
        if (last >= 0 && !_messages[last].isUser) {
          setState(() {
            _messages[last] = _messages[last].copyWith(docId: id);
          });
        }
      },
      onError: (e) async {
        debugPrint('Gemini error: $e');
        if (!mounted) return;
        final errMsg = e.toString();
        String display;
        if (errMsg.contains('API_KEY_INVALID') || errMsg.contains('invalid') || errMsg.contains('API key')) {
          display = 'API key tidak valid. Pastikan key benar (format AIza...) di gemini_config.dart.';
        } else if (errMsg.contains('PERMISSION_DENIED')) {
          display = 'Akses ditolak. Pastikan Generative Language API sudah diaktifkan di Google Cloud Console.';
        } else if (errMsg.contains('quota') || errMsg.contains('RESOURCE_EXHAUSTED')) {
          display = 'Batas penggunaan harian tercapai. Coba lagi besok atau upgrade plan.';
        } else if (errMsg.contains('SocketException') || errMsg.contains('network')) {
          display = 'Tidak ada koneksi internet. Periksa jaringan dan coba lagi.';
        } else {
          display = 'Error: $errMsg';
        }
        setState(() {
          _messages.removeWhere((m) => m.isLoading);
          _messages.add(_ChatMessage(text: display, isUser: false));
          _isResponding = false;
        });
        final id = await MajaAiHistoryService.add(text: display, isUser: false);
        if (!mounted || id == null) return;
        final last = _messages.length - 1;
        if (last >= 0 && !_messages[last].isUser) {
          setState(() {
            _messages[last] = _messages[last].copyWith(docId: id);
          });
        }
      },
      cancelOnError: true,
    );
  }

  void _stop() {
    _streamSub?.cancel();
    _streamSub = null;
    String? savedText;
    setState(() {
      if (_messages.isNotEmpty && _messages.last.isLoading) {
        final lastText = _messages.last.text;
        if (lastText.isEmpty) {
          _messages.removeLast();
        } else {
          _messages[_messages.length - 1] = _ChatMessage(
            text: lastText,
            isUser: false,
          );
          savedText = lastText;
        }
      }
      _isResponding = false;
    });
    if (savedText != null) {
      MajaAiHistoryService.add(text: savedText!, isUser: false).then((id) {
        if (!mounted || id == null) return;
        final last = _messages.length - 1;
        if (last >= 0 && !_messages[last].isUser) {
          setState(() {
            _messages[last] = _messages[last].copyWith(docId: id);
          });
        }
      });
    }
  }

  // ── Salin pesan & snackbar helper ──────────────────────────────────────────

  Future<void> _copyMessage(String text) async {
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _showSnack('Pesan disalin ke clipboard');
  }

  void _showSnack(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppTheme.danger : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final stillLoading = _isLoadingUser || _isLoadingHistory;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: stillLoading ? _buildSkeleton() : _buildChat(),
      ),
    );
  }

  // ── Skeleton ───────────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: [
              _skel(width: 44, height: 44, radius: 22),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skel(width: 130, height: 13),
                  const SizedBox(height: 6),
                  _skel(width: 90, height: 11),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(children: [
            _skel(width: double.infinity, height: 13),
            const SizedBox(height: 10),
            _skel(width: double.infinity, height: 13),
            const SizedBox(height: 10),
            _skel(width: 180, height: 13),
            const SizedBox(height: 10),
            _skel(width: 140, height: 13),
          ]),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _skel(width: double.infinity, height: 52, radius: 999),
        ),
      ],
    );
  }

  Widget _skel({required double width, required double height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(220, 220, 220, 1),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Chat ───────────────────────────────────────────────────────────────────

  Widget _buildChat() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) => _buildBubble(_messages[i]),
                ),
        ),
        _buildInput(),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color.fromRGBO(220, 232, 255, 1),
            child: ClipOval(
              child: Image.asset(
                'assets/images/maja_ai.png',
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    '$_greeting ',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Text('👋', style: TextStyle(fontSize: 15)),
                ]),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_messages.isNotEmpty)
            IconButton(
              tooltip: 'Hapus riwayat',
              onPressed: _isResponding ? null : _confirmClearHistory,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: _isResponding ? AppTheme.textSecondary : AppTheme.danger,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/maja_ai.png',
              width: 90,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tanya aku apa saja!',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aku siap membantu kamu memahami\nlayanan pemerintah Jawa Timur.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _suggestions.map(_quickChip).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(String label) {
    return GestureDetector(
      onTap: () {
        _textCtrl.text = label;
        _send();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color.fromRGBO(210, 228, 255, 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }

  // ── Bubble ─────────────────────────────────────────────────────────────────

  Widget _buildBubble(_ChatMessage msg) {
    if (msg.isUser) return _buildUserBubble(msg.text);
    // Loading pill (belum ada teks)
    if (msg.isLoading && msg.text.isEmpty) return _buildLoadingPill();
    // Streaming bubble (teks sedang masuk) + tombol stop di bawah
    if (msg.isLoading && msg.text.isNotEmpty) return _buildStreamingBubble(msg.text);
    // Bubble respons final
    return _buildAiBubble(msg.text);
  }

  Widget _buildUserBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyMessage(text),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color.fromRGBO(220, 232, 255, 1),
            backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
            child: _photoUrl.isEmpty
                ? const Icon(Icons.person_rounded, color: AppTheme.primary, size: 16)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAiBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _aiAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyMessage(text),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamingBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _aiAvatar(),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Tombol stop saat streaming
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 6, bottom: 8),
            child: GestureDetector(
              onTap: _stop,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 65, 108, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stop_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'Stop Merespon',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPill() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _aiAvatar(),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _stop,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 65, 108, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '•••',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Stop Merespon',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color.fromRGBO(220, 232, 255, 1),
      child: ClipOval(
        child: Image.asset(
          'assets/images/maja_ai.png',
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 16),
        ),
      ),
    );
  }

  // ── Input ──────────────────────────────────────────────────────────────────

  Widget _buildInput() {
    return Container(
      color: AppTheme.background,
      padding: EdgeInsets.fromLTRB(
        16, 8, 16,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _textCtrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                enabled: !_isResponding,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Tanyakan apapun',
                  hintStyle: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    color: Color.fromRGBO(180, 180, 180, 1),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isResponding ? null : _send,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _isResponding
                    ? const Color.fromRGBO(200, 200, 200, 1)
                    : AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isLoading;
  final String? docId;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
    this.docId,
  });

  _ChatMessage copyWith({
    String? text,
    bool? isUser,
    bool? isLoading,
    String? docId,
  }) {
    return _ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isLoading: isLoading ?? this.isLoading,
      docId: docId ?? this.docId,
    );
  }
}

// ── Suggestion chip data ─────────────────────────────────────────────────────

const Map<String, List<String>> _kSuggestionsByFeature = {
  'bapenda': ['Cek pajak kendaraan', 'Estimasi NJKB'],
  'rsud': ['Cek antrean rumah sakit', 'Cari kamar tersedia'],
  'transjatim': ['Jadwal & rute Transjatim'],
  'siskaperbapo': ['Harga bahan pokok'],
  'nomor_darurat': ['Nomor darurat penting'],
  'sapa_bansos': ['Cek bantuan sosial'],
  'klinik_hoaks': ['Cek klaim hoaks'],
  'open_data': ['Lihat open data'],
  'etibi': ['Bayar tilang elektronik'],
};

/// List default ketika user belum punya riwayat pembukaan fitur.
/// Dibuat const-evaluable lewat class wrapper agar bisa dipakai sebagai
/// initial value dari `_suggestions`.
class _DefaultSuggestionsList extends ListBase<String> {
  const _DefaultSuggestionsList();

  static const List<String> _items = [
    'Cek pajak kendaraan',
    'Info rumah sakit',
    'Harga bahan pokok',
    'Bantuan sosial',
    'Nomor darurat',
    'Cara pakai aplikasi',
  ];

  @override
  int get length => _items.length;

  @override
  String operator [](int index) => _items[index];

  @override
  void operator []=(int index, String value) =>
      throw UnsupportedError('Default suggestions are immutable');

  @override
  set length(int newLength) =>
      throw UnsupportedError('Default suggestions are immutable');
}
