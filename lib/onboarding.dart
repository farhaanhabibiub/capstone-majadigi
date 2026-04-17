import 'package:flutter/material.dart';
import 'app_route.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/onboarding1.png',
      'titleBlack': 'Selamat Datang di ',
      'titleBlue': 'Majadigi!',
      'description':
      'Akses berbagai layanan Pemerintah Provinsi dan Kabupaten/Kota Jawa Timur dalam satu aplikasi terpadu',
    },
    {
      'image': 'assets/images/onboarding2.png',
      'titleBlack': 'Selesaikan Layanan ',
      'titleBlue': 'Tanpa Ribet',
      'description':
      'Tidak perlu lagi berpindah-pindah platform, akses dan selesaikan layanan langsung di dalam aplikasi',
    },
    {
      'image': 'assets/images/onboarding3.png',
      'titleBlack': 'Layanan yang ',
      'titleBlue': 'Relevan untuk Anda',
      'description':
      'Pilih kategori layanan yang paling sering Anda gunakan, dan nikmati dashboard yang lebih sederhana, fokus, dan mudah diakses kapan saja',
    },
    {
      'image': 'assets/images/onboarding4.png',
      'titleBlue': 'Satu Akun ',
      'titleBlack': 'untuk Semua Layanan',
      'description':
      'Dengan sistem autentikasi terpadu, Anda dapat mengelola layanan lintas instansi secara aman dan terintegrasi dalam satu akun.',
    },
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToLastPage() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToLogin() {
    Navigator.pushNamed(context, AppRoutes.loginPage);
  }

  void _goToRegister() {
    Navigator.pushNamed(context, AppRoutes.registerPage);
  }

  Widget _buildIndicator(int index) {
    final bool isActive = index == _currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6),
      width: isActive ? 27 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive
            ? const Color.fromRGBO(0, 101, 255, 1)
            : const Color.fromRGBO(210, 210, 210, 1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildTitle(Map<String, String> page, int index) {
    if (index == 3) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: page['titleBlue'],
              style: const TextStyle(
                color: Color.fromRGBO(0, 101, 255, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            TextSpan(
              text: page['titleBlack'],
              style: const TextStyle(
                color: Color.fromRGBO(32, 32, 32, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: page['titleBlack'],
        style: const TextStyle(
          color: Color.fromRGBO(32, 32, 32, 1),
          fontFamily: 'PlusJakartaSans',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        children: [
          TextSpan(
            text: page['titleBlue'],
            style: const TextStyle(
              color: Color.fromRGBO(0, 101, 255, 1),
              fontFamily: 'PlusJakartaSans',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, String> page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 75),

          Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(page['image']!),
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 28),

          _buildTitle(page, index),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              page['description']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromRGBO(90, 90, 90, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 42),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (indicatorIndex) {
              return _buildIndicator(indicatorIndex);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    if (_isLastPage) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _goToLogin,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 101, 255, 1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Masuk',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PlusJakartaSans',
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
                    border: Border.all(
                      color: const Color.fromRGBO(0, 101, 255, 1),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Daftar',
                    style: TextStyle(
                      color: Color.fromRGBO(0, 101, 255, 1),
                      fontFamily: 'PlusJakartaSans',
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _skipToLastPage,
            child: const Text(
              'Lewati',
              style: TextStyle(
                color: Color.fromRGBO(32, 32, 32, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 101, 255, 1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
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
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (value) {
                    setState(() {
                      _currentPage = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], index);
                  },
                ),
              ),
              _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }
}