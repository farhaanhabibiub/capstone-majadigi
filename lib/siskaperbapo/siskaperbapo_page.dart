import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_service.dart';
import 'models/sembako_model.dart';
import 'data/sembako_dummy_data.dart';
import 'widgets/sembako_card.dart';
import 'widgets/indicator_badge.dart';
import 'widgets/info_card.dart';
import 'widgets/price_graph_painter.dart';

class SiskaperbapoPage extends StatefulWidget {
  const SiskaperbapoPage({super.key});

  @override
  State<SiskaperbapoPage> createState() => _SiskaperbapoPageState();
}

class _SiskaperbapoPageState extends State<SiskaperbapoPage> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  int _selectedTabIndex = 0;
  String _searchQuery = '';
  SembakoItem? _selectedItem;
  bool _isExpanded = false;
  int _selectedKabupatenIndex = 0;
  String? _userRegency;
  String? _selectedKabupatenFilter;
  bool _isFavorite = false;

  static const String _favKey = 'fav_siskaperbapo';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserRegency();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _isFavorite = prefs.getBool(_favKey) ?? false);
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final next = !_isFavorite;
    await prefs.setBool(_favKey, next);
    if (!mounted) return;
    setState(() => _isFavorite = next);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: next ? _blue : const Color.fromRGBO(100, 100, 100, 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(
              next ? Icons.bookmark_rounded : Icons.bookmark_remove_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              next
                  ? 'SISKAPERBAPO ditambahkan ke favorit'
                  : 'SISKAPERBAPO dihapus dari favorit',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRegency() async {
    final profile = await AuthService.instance.getUserProfile();
    if (!mounted) return;
    final location = profile?['location'] as Map<String, dynamic>?;
    setState(() {
      _userRegency = location?['regency'] as String?;
    });
  }

  int _findKabupatenIndex(List<KabupatenPrice> kabupatenPrices) {
    if (_userRegency == null || _userRegency!.trim().isEmpty) return 0;
    final query = _userRegency!.toLowerCase().trim();
    final queryStripped = query.replaceFirst(RegExp(r'^(kabupaten |kota )'), '');

    // Pass 1: exact match (e.g. "Kota Malang" → "Kota Malang", not "Kabupaten Malang")
    for (int i = 0; i < kabupatenPrices.length; i++) {
      if (kabupatenPrices[i].kabupaten.toLowerCase() == query) return i;
    }

    // Pass 2: same-prefix stripped match (kota→kota, kabupaten→kabupaten)
    final prefix = query.startsWith('kota ') ? 'kota '
        : query.startsWith('kabupaten ') ? 'kabupaten '
        : null;
    if (prefix != null) {
      for (int i = 0; i < kabupatenPrices.length; i++) {
        final name = kabupatenPrices[i].kabupaten.toLowerCase();
        if (name.startsWith(prefix) && name.substring(prefix.length) == queryStripped) {
          return i;
        }
      }
    }

    // Pass 3: loose stripped fallback (for queries with no prefix like "Surabaya")
    for (int i = 0; i < kabupatenPrices.length; i++) {
      final name = kabupatenPrices[i].kabupaten.toLowerCase();
      final nameStripped = name.replaceFirst(RegExp(r'^(kabupaten |kota )'), '');
      if (nameStripped == queryStripped ||
          name.contains(queryStripped) || queryStripped.contains(nameStripped)) {
        return i;
      }
    }
    return 0;
  }

  List<String> get _allKabupaten {
    if (SembakoDummyData.items.isEmpty) return [];
    return SembakoDummyData.items[0].kabupatenPrices.map((k) => k.kabupaten).toList();
  }

  List<SembakoItem> get _filteredItems {
    if (_searchQuery.isEmpty) return SembakoDummyData.items;
    return SembakoDummyData.items
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _isExpanded = false;
    });
    await _loadUserRegency();
  }

  String _formatRupiah(int number) {
    String str = number.toString();
    String result = '';
    for (int i = 0; i < str.length; i++) {
        result += str[i];
        if ((str.length - 1 - i) % 3 == 0 && i != str.length - 1) {
            result += '.';
        }
    }
    return 'Rp $result';
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
          onPressed: () {
            if (_selectedItem != null) {
              setState(() {
                _selectedItem = null;
                _isExpanded = false;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'SISKAPERBAPO',
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
              icon: Icon(
                _isFavorite
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: _blue,
                size: 20,
              ),
              onPressed: _toggleFavorite,
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
                  child: _selectedItem != null
                      ? _buildDetailView()
                      : _buildMainView(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildTabSwitcher(),
        const SizedBox(height: 24),
        Expanded(
          child: _selectedTabIndex == 0
              ? _buildHargaTabView()
              : _buildInformasiTabView(),
        ),
      ],
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
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 0 ? _blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Harga Bahan Pokok',
                    style: TextStyle(
                      color: _selectedTabIndex == 0 ? Colors.white : _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 1 ? _blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Informasi',
                    style: TextStyle(
                      color: _selectedTabIndex == 1 ? Colors.white : _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  Widget _buildHargaTabView() {
    final listDitampilkan = _isExpanded ? _filteredItems : _filteredItems.take(5).toList();
    final kabupaten = _allKabupaten;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSearchBar(),
        ),
        const SizedBox(height: 12),
        // Kabupaten filter chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: kabupaten.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final isAll = i == 0;
              final label = isAll ? 'Semua' : kabupaten[i - 1];
              final isSelected = isAll
                  ? _selectedKabupatenFilter == null
                  : _selectedKabupatenFilter == label;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedKabupatenFilter = isAll ? null : label;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? _blue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? _blue : const Color(0xFFE0E0E0)),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _textSecondary,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedKabupatenFilter != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Harga di $_selectedKabupatenFilter',
              style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12),
            ),
          ),
        if (_selectedKabupatenFilter == null)
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Harga Rata - Rata',
              style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: _blue,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index.isOdd) {
                                return const SizedBox(height: 12);
                              }
                              final itemIndex = index ~/ 2;
                              return SembakoCard(
                                item: listDitampilkan[itemIndex],
                                onTap: () {
                                  final tapped = listDitampilkan[itemIndex];
                                  int kabIndex = _selectedKabupatenFilter != null
                                      ? tapped.kabupatenPrices.indexWhere(
                                          (k) => k.kabupaten == _selectedKabupatenFilter)
                                      : -1;
                                  if (kabIndex < 0) kabIndex = _findKabupatenIndex(tapped.kabupatenPrices);
                                  setState(() {
                                    _selectedItem = tapped;
                                    _selectedKabupatenIndex = kabIndex;
                                  });
                                },
                                formatRupiah: _formatRupiah,
                              );
                            },
                            childCount: listDitampilkan.length * 2 - 1,
                          ),
                        ),
                      ),
                      if (_searchQuery.isEmpty && !_isExpanded && _filteredItems.length > 5)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
                            child: OutlinedButton(
                              onPressed: () => setState(() => _isExpanded = true),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _blue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                'Lihat Lebih Banyak',
                                style: TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _blue),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(
                color: _blue,
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari barang...',
                hintStyle: TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontFamily: 'PlusJakartaSans',
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Cari',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Hasil tidak ditemukan',
            style: TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mohon coba kata kunci yang lain',
            style: TextStyle(
              color: _textSecondary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformasiTabView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: const [
        InfoCard(
          title: 'Tentang SISKAPERBAPO',
          subtitle: 'Lebih tahu tentang SISKAPERBAPO',
          icon: Icons.info_outline,
          content:
              'SISKAPERBAPO, singkatan dari Sistem Informasi Ketersediaan dan Perkembangan Harga Bahan Pokok. Dia adalah portal berbasis online yang menyajikan info tren harga dan ketersediaan bahan pokok harian dari seluruh area di Jawa Timur. Diantaranya beras, minyak goreng, sayur mayur, ikan segar, produk olahan, perlengkapan rumah tangga, dan komoditas lain. SISKAPERBAPO menyajikan informasi update harga di tingkat konsumen dan produsen, terutama di sentra produksi.',
        ),
        SizedBox(height: 16),
        InfoCard(
          title: 'Sumber Data',
          subtitle: 'Sumber Data SISKAPERBAPO',
          icon: Icons.storage,
          content:
              'SISKAPERBAPO menggunakan data yang bersumber dari Dinas Perindustrian dan Perdagangan Provinsi Jawa Timur. Informasi harga diperbarui setiap hari pada pukul 00.00 WIB.',
        ),
      ],
    );
  }

  Widget _buildDetailView() {
    final item = _selectedItem!;
    final selectedKab = item.kabupatenPrices[_selectedKabupatenIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${_formatRupiah(item.price)} / kg',
                          style: const TextStyle(
                            color: _textPrimary,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IndicatorBadge(status: item.status, statusText: item.statusText),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const CircleAvatar(
                    backgroundColor: Color.fromRGBO(0, 101, 255, 0.1),
                    child: Icon(Icons.food_bank_outlined, color: _blue, size: 30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Location indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(235, 243, 255, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: _blue, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      _userRegency != null
                          ? item.kabupatenPrices[_selectedKabupatenIndex].kabupaten
                          : 'Memuat lokasi...',
                      style: const TextStyle(
                        color: _blue,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (item.historyDates.isNotEmpty)
                Text(
                  'Data per ${item.historyDates.last}',
                  style: const TextStyle(
                    color: _textSecondary,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grafik Harga',
                style: TextStyle(
                  color: _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                item.kabupatenPrices[_selectedKabupatenIndex].kabupaten,
                style: const TextStyle(
                  color: _textSecondary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Graph area
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
            child: CustomPaint(
              painter: PriceGraphPainter(
                prices: selectedKab.historyPrices,
                dates: selectedKab.historyDates,
                formatPrice: _formatRupiah,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Kabupaten/Kota price card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Color.fromRGBO(0, 101, 255, 0.1),
                      child: Icon(Icons.payments, color: _blue, size: 18),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Harga per Kecamatan',
                      style: TextStyle(
                        color: _textPrimary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Kabupaten dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: _blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedKabupatenIndex,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _blue),
                      style: const TextStyle(
                        color: _textPrimary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedKabupatenIndex = val);
                      },
                      items: List.generate(item.kabupatenPrices.length, (i) {
                        return DropdownMenuItem(
                          value: i,
                          child: Text(item.kabupatenPrices[i].kabupaten),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, thickness: 1, color: Color.fromRGBO(235, 235, 235, 1)),
                const SizedBox(height: 20),
                // Kecamatan sub-section
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(248, 248, 245, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Rincian per Kecamatan',
                            style: TextStyle(
                              color: _textSecondary,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            '${item.kabupatenPrices[_selectedKabupatenIndex].kecamatanPrices.length} kecamatan',
                            style: const TextStyle(
                              color: _textSecondary,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...item.kabupatenPrices[_selectedKabupatenIndex].kecamatanPrices.map((kp) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  kp.kecamatan,
                                  style: const TextStyle(
                                    color: _textPrimary,
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatRupiah(kp.price),
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
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
