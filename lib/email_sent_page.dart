import 'package:flutter/material.dart';
import 'app_route.dart';
import 'auth_service.dart';

class EmailSentPage extends StatefulWidget {
  final String email;

  const EmailSentPage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<EmailSentPage> createState() => _EmailSentPageState();
}

class _EmailSentPageState extends State<EmailSentPage> {
  bool _isResending = false;

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  Future<void> _handleResend() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final result = await AuthService.instance.sendPasswordResetEmail(
        email: widget.email,
      );

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

  void _goToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.loginPage,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color.fromRGBO(32, 32, 32, 1),
                ),
              ),
              const SizedBox(height: 36),
              const Center(
                child: Text(
                  'Email telah dikirim!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textPrimary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Silakan periksa kotak masuk Anda dan klik tautan\nyang diterima untuk mereset kata sandi',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 34),
              Center(
                child: Image.asset(
                  'assets/images/email_sent_icon.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 180,
                      height: 180,
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 100,
                        color: _blue,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _goToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Belum menerima tautan? ',
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}