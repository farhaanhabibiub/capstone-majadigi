import 'package:flutter/material.dart';
import 'app_route.dart';
import 'auth_service.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isChecking = false;
  bool _isResending = false;

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _cardBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _titleColor = Color.fromRGBO(32, 32, 32, 1);
  static const Color _subtitleColor = Color.fromRGBO(140, 140, 140, 1);
  static const Color _overlayBg = Color.fromRGBO(58, 58, 58, 1);

  Future<void> _handleResend() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final result = await AuthService.instance.resendVerificationEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _handleGoToLogin() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final result = await AuthService.instance.refreshVerificationStatus();

      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
        return;
      }

      await AuthService.instance.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginPage,
            (route) => false,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email berhasil diverifikasi. Silakan login.'),
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _overlayBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/email_verification.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Email Verifikasi Terkirim!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _titleColor,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tautan verifikasi telah dikirim ke email\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _subtitleColor,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isChecking ? null : _handleGoToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        disabledBackgroundColor:
                        const Color.fromRGBO(210, 210, 210, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isChecking ? 'Memeriksa...' : 'Masuk',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Belum menerima tautan? ',
                        style: TextStyle(
                          color: _subtitleColor,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isResending ? null : _handleResend,
                        child: Text(
                          _isResending ? 'Mengirim...' : 'Kirim kembali',
                          style: const TextStyle(
                            color: _blue,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}