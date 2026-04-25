import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class KeamananAkunPage extends StatefulWidget {
  const KeamananAkunPage({super.key});

  @override
  State<KeamananAkunPage> createState() => _KeamananAkunPageState();
}

class _KeamananAkunPageState extends State<KeamananAkunPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isSaving = false;

  static const Color _textHint = Color.fromRGBO(180, 180, 180, 1);

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      // Re-autentikasi dengan password lama
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPassCtrl.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPassCtrl.text);

      if (!mounted) return;
      _showSuccess();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'wrong-password' || 'invalid-credential' => 'Password lama tidak sesuai.',
        'weak-password' => 'Password baru terlalu lemah. Minimal 6 karakter.',
        'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
        'network-request-failed' => 'Koneksi internet bermasalah.',
        _ => 'Gagal mengubah password. (${e.code})',
      };
      _showError(msg);
    } catch (_) {
      if (mounted) _showError('Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(
              'Password berhasil diperbarui',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
        title: const Text(
          'Keamanan Akun',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubah Password',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Password Lama ───────────────────────────────────────
                    _fieldLabel('Password Lama'),
                    const SizedBox(height: 8),
                    _passwordField(
                      controller: _oldPassCtrl,
                      hint: '••••••••',
                      obscure: !_showOld,
                      onToggle: () => setState(() => _showOld = !_showOld),
                      action: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password lama tidak boleh kosong';
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // ── Password Baru ───────────────────────────────────────
                    _fieldLabel('Password Baru'),
                    const SizedBox(height: 8),
                    _passwordField(
                      controller: _newPassCtrl,
                      hint: '••••••••',
                      obscure: !_showNew,
                      onToggle: () => setState(() => _showNew = !_showNew),
                      action: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password baru tidak boleh kosong';
                        if (v.length < 6) return 'Minimal 6 karakter';
                        if (v == _oldPassCtrl.text) return 'Password baru tidak boleh sama dengan yang lama';
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // ── Konfirmasi Password Baru ────────────────────────────
                    _fieldLabel('Konfirmasi Password Baru'),
                    const SizedBox(height: 8),
                    _passwordField(
                      controller: _confirmPassCtrl,
                      hint: '••••••••',
                      obscure: !_showConfirm,
                      onToggle: () => setState(() => _showConfirm = !_showConfirm),
                      action: TextInputAction.done,
                      onSubmitted: (_) => _simpan(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                        if (v != _newPassCtrl.text) return 'Password tidak cocok';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Tombol Simpan ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: const Color.fromRGBO(210, 210, 210, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontFamily: AppTheme.fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required TextInputAction action,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontFamily: AppTheme.fontFamily,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _textHint,
          fontFamily: AppTheme.fontFamily,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppTheme.textSecondary,
            size: 20,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Color.fromRGBO(225, 225, 225, 1), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppTheme.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppTheme.danger, width: 1.4),
        ),
        errorStyle: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 11,
        ),
      ),
    );
  }
}
