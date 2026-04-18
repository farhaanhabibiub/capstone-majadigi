import 'package:flutter/material.dart';
import 'widgets/skrining_tab.dart';
import 'widgets/riwayat_tab.dart';
import 'widgets/tentang_tab.dart';
import 'models/etibi_model.dart';
import 'data/etibi_dummy_data.dart';

class EtibiPage extends StatefulWidget {
  const EtibiPage({Key? key}) : super(key: key);

  @override
  State<EtibiPage> createState() => _EtibiPageState();
}

class _EtibiPageState extends State<EtibiPage> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);

  int _selectedTabIndex = 0;
  late List<RiwayatSkrining> _riwayatList;

  @override
  void initState() {
    super.initState();
    _riwayatList = List.from(EtibiDummyData.riwayatList);
  }

  void _tambahRiwayat(RiwayatSkrining riwayatBaru) {
    setState(() {
      _riwayatList.insert(0, riwayatBaru);
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = kToolbarHeight + statusBarHeight + 36;

    return Scaffold(
      backgroundColor: _blue,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'E-TIBI',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Image.asset('assets/images/Bookmark.png', width: 18, height: 18, errorBuilder: (c,e,s) => const Icon(Icons.bookmark_border, color: _blue, size: 18)),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight + 50,
            child: Container(
              decoration: const BoxDecoration(
                color: _blue,
                image: DecorationImage(
                  image: AssetImage('assets/images/tekstur.png'),
                  fit: BoxFit.cover,
                  opacity: 0.15,
                ),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: headerHeight),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _whiteBg,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildTabSwitcher(),
                      Expanded(
                        child: _selectedTabIndex == 1 
                         ? Padding(padding: const EdgeInsets.all(16), child: RiwayatTab(riwayatList: _riwayatList))
                         : SingleChildScrollView(
                             padding: const EdgeInsets.all(16),
                             child: _buildCurrentTab(),
                           ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _buildTabItem('Skrining', 0),
            _buildTabItem('Riwayat', 1),
            _buildTabItem('Tentang', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? _blue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedTabIndex) {
      case 0:
        return SkriningTab(onSubmit: _tambahRiwayat);
      case 2:
        return const TentangTab();
      default:
        return SkriningTab(onSubmit: _tambahRiwayat);
    }
  }
}
