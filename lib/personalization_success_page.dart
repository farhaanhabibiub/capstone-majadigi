import 'dart:async';

import 'package:flutter/material.dart';

import 'app_route.dart';

class PersonalizationSuccessPage extends StatefulWidget {
  const PersonalizationSuccessPage({super.key});

  @override
  State<PersonalizationSuccessPage> createState() =>
      _PersonalizationSuccessPageState();
}

class _PersonalizationSuccessPageState
    extends State<PersonalizationSuccessPage> {
  Timer? _timer;

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.berandaPage,
            (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: _whiteBg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/personalization_success.png',
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 170,
                        height: 170,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(235, 243, 255, 1),
                        ),
                        child: const Center(
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: _blue,
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 46,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Beranda Siap Digunakan!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _blue,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(_blue),
                    ),
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