import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_route.dart';
import 'theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const String seenKey = 'onboarding_seen';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnbSlide> _slides = [
    _OnbSlide(
      image: 'assets/images/onboarding1.png',
      titleBlack: 'Selamat Datang di ',
      titleBlue: 'Majadigi!',
      description:
          'Akses berbagai layanan Pemerintah Provinsi dan Kabupaten/Kota Jawa Timur dalam satu aplikasi terpadu.',
    ),
    _OnbSlide(
      image: 'assets/images/onboarding2.png',
      titleBlack: 'Selesaikan Layanan ',
      titleBlue: 'Tanpa Ribet',
      description:
          'Tidak perlu lagi berpindah-pindah platform. Akses dan selesaikan layanan langsung di dalam aplikasi.',
    ),
    _OnbSlide(
      image: 'assets/images/onboarding3.png',
      titleBlack: 'Layanan yang ',
      titleBlue: 'Relevan untuk Anda',
      description:
          'Pilih kategori layanan yang sering Anda gunakan, nikmati dashboard yang sederhana dan fokus.',
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  Future<void> _markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingPage.seenKey, true);
  }

  void _nextPage() {
    if (_isLastPage) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _skip() {
    _pageController.animateToPage(
      _slides.length - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _goToLogin() async {
    await _markSeen();
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.loginPage);
  }

  Future<void> _goToRegister() async {
    await _markSeen();
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.registerPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(150, 192, 255, 1),
              Color.fromRGBO(255, 255, 250, 1),
            ],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (v) => setState(() => _currentPage = v),
                  itemBuilder: (_, i) => _buildPage(_slides[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, _buildIndicator),
                ),
              ),
              _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedOpacity(
              opacity: _isLastPage ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: _isLastPage ? null : _skip,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
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

  Widget _buildPage(_OnbSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            flex: 5,
            child: Image.asset(slide.image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: AppTheme.fontFamily,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              children: [
                TextSpan(text: slide.titleBlack),
                TextSpan(
                  text: slide.titleBlue,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromRGBO(90, 90, 90, 1),
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildIndicator(int i) {
    final active = i == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? AppTheme.primary
            : const Color.fromRGBO(210, 210, 210, 1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildBottomAction() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _isLastPage ? _buildLastPageActions() : _buildNextAction(),
    );
  }

  Widget _buildNextAction() {
    return Padding(
      key: const ValueKey('next'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastPageActions() {
    return Padding(
      key: const ValueKey('last'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _goToLogin,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Masuk',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _goToRegister,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppTheme.primary, width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Daftar',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnbSlide {
  final String image;
  final String titleBlack;
  final String titleBlue;
  final String description;

  const _OnbSlide({
    required this.image,
    required this.titleBlack,
    required this.titleBlue,
    required this.description,
  });
}
