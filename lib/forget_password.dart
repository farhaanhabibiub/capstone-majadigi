import 'package:flutter/material.dart';
import 'app_route.dart';
import 'auth_service.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  bool _isSubmitting = false;
  bool _showValidationErrors = false;

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_refresh);
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email wajib diisi';

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(text)) return 'Format email tidak valid';

    return null;
  }

  bool get _isFormFilled => _emailController.text.trim().isNotEmpty;

  Future<void> _handleSendResetEmail() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _showValidationErrors = true;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await AuthService.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.emailSentPage,
        arguments: {
          'email': _emailController.text.trim(),
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: _showValidationErrors
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
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
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Lupa kata sandi?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Silakan masukkan alamat email Anda untuk\nmenerima kode verifikasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textSecondary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Image.asset(
                    'assets/images/forgot_password_mail.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        width: 180,
                        height: 180,
                        child: Icon(
                          Icons.mail_outline,
                          size: 100,
                          color: _blue,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                _ForgetPasswordTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Ingat kata sandi? ',
                        style: TextStyle(
                          color: Color.fromRGBO(140, 140, 140, 1),
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.loginPage,
                          );
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
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
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (_isFormFilled && !_isSubmitting)
                        ? _handleSendResetEmail
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      disabledBackgroundColor:
                      const Color.fromRGBO(210, 210, 210, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isSubmitting ? 'Memproses...' : 'Kirim',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgetPasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const _ForgetPasswordTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.validator,
  });

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _hint = Color.fromRGBO(140, 140, 140, 1);
  static const Color _gray = Color.fromRGBO(170, 170, 170, 1);

  @override
  Widget build(BuildContext context) {
    final bool isFilled = controller.text.trim().isNotEmpty;
    final Color borderColor = isFilled ? _blue : _gray;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(
        color: _blue,
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: _hint,
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: borderColor,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: borderColor,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(
            color: _blue,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.4,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 11,
          height: 1.2,
          color: Colors.red,
        ),
      ),
    );
  }
}