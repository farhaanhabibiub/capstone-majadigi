import 'package:flutter/material.dart';
import 'models/sembako_model.dart';
import 'data/sembako_dummy_data.dart';
import 'widgets/sembako_card.dart';
import 'widgets/indicator_badge.dart';
import 'widgets/info_card.dart';
import 'widgets/price_graph_painter.dart';

class SiskaperbapoPage extends StatefulWidget {
  const SiskaperbapoPage({Key? key}) : super(key: key);

  @override
  State<SiskaperbapoPage> createState() => _SiskaperbapoPageState();
}

class _SiskaperbapoPageState extends State<SiskaperbapoPage> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  int _selectedTabIndex = 0; // 0 for Harga Bahan Pokok, 1 for Informasi
  String _searchQuery = '';
  SembakoItem? _selectedItem;
  bool _isExpanded = false;

  final TextEditingController _searchController = TextEditingController();

  List<SembakoItem> get _filteredItems {
    if (_searchQuery.isEmpty) return SembakoDummyData.items;
    return SembakoDummyData.items
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSearchBar(),
        ),
        const SizedBox(height: 16),
        if (_searchQuery.isNotEmpty || SembakoDummyData.items.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Harga Rata - Rata',
              style: TextStyle(
                color: _textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index.isOdd) {
                              return const SizedBox(height: 12); // Separator
                            }
                            final itemIndex = index ~/ 2;
                            return SembakoCard(
                              item: listDitampilkan[itemIndex],
                              onTap: () {
                                setState(() {
                                  _selectedItem = listDitampilkan[itemIndex];
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
                            onPressed: () {
                              setState(() {
                                _isExpanded = true;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Lihat Lebih Banyak',
                              style: TextStyle(
                                color: _blue,
                                fontFamily: 'PlusJakartaSans',
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
            onTap: () {
              // trigger search if needed, already done on onChanged
            },
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
          const SizedBox(height: 32),
          const Text(
            'Grafik Harga',
            style: TextStyle(
              color: _textPrimary,
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Graph area
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
            child: CustomPaint(
              painter: PriceGraphPainter(
                prices: item.historyPrices,
                dates: item.historyDates,
                formatPrice: _formatRupiah,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // City prices card
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
                      'Harga di Kab/Kota',
                      style: TextStyle(
                        color: _textPrimary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...item.cityPrices.map((cityPrice) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cityPrice.city,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatRupiah(cityPrice.price),
                          style: const TextStyle(
                            color: _textPrimary,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
