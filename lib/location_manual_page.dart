import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'auth_service.dart';

class LocationManualPage extends StatefulWidget {
  const LocationManualPage({super.key});

  @override
  State<LocationManualPage> createState() => _LocationManualPageState();
}

class _LocationManualPageState extends State<LocationManualPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<JatimLocationItem> _allLocations = [];
  List<JatimLocationItem> _filteredLocations = [];

  Timer? _debounce;
  bool _isLoading = true;
  bool _isSaving = false;

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);
  static const Color _textHint = Color.fromRGBO(140, 140, 140, 1);
  static const Color _borderGray = Color.fromRGBO(170, 170, 170, 1);
  static const Color _dividerColor = Color.fromRGBO(225, 225, 225, 1);

  @override
  void initState() {
    super.initState();
    _loadCsvData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCsvData() async {
    try {
      final raw = await rootBundle.loadString('assets/data/jatim_kecamatan.csv');

      // Remove BOM if present
      final cleanedRaw = raw.replaceFirst('\uFEFF', '');
      
      // Split into lines and filter out empty ones
      final lines = cleanedRaw.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
      
      if (lines.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Detect delimiter (comma or semicolon)
      final firstLine = lines.first;
      final delimiter = firstLine.contains(';') && !firstLine.contains(',') ? ';' : ',';

      // Parse rows manually by splitting each line by the detected delimiter
      final List<List<String>> rows = lines.map((line) => line.split(delimiter)).toList();

      final header = rows.first
          .map((e) => _normalizeHeader(e.trim()))
          .toList();

      int findHeader(List<String> aliases, {bool required = true}) {
        for (final alias in aliases) {
          final index = header.indexOf(alias);
          if (index != -1) return index;
        }

        if (required) {
          throw Exception(
            'Header CSV tidak cocok. Header ditemukan: ${header.join(', ')}',
          );
        }

        return -1;
      }

      final kecamatanIndex = findHeader(['kecamatan']);
      final kabupatenIndex = findHeader([
        'kabupaten',
        'kabupaten_kota',
        'kabupaten_kota_',
        'kabupatenkota',
      ]);
      final provinsiIndex = findHeader(['provinsi']);

      final kodeKecamatanIndex =
      findHeader(['kode_kecamatan'], required: false);
      final kodeKabupatenIndex =
      findHeader(['kode_kabupaten'], required: false);
      final kodeProvinsiIndex =
      findHeader(['kode_provinsi'], required: false);

      final maxRequiredIndex = [
        kecamatanIndex,
        kabupatenIndex,
        provinsiIndex,
      ].reduce((a, b) => a > b ? a : b);

      final items = <JatimLocationItem>[];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length <= maxRequiredIndex) continue;

        final kecamatan = row[kecamatanIndex].trim();
        final kabupaten = row[kabupatenIndex].trim();
        final provinsi = row[provinsiIndex].trim();

        if (kecamatan.isEmpty || kabupaten.isEmpty || provinsi.isEmpty) {
          continue;
        }

        final kodeKecamatan =
        (kodeKecamatanIndex != -1 && row.length > kodeKecamatanIndex)
            ? row[kodeKecamatanIndex].trim()
            : '';

        final kodeKabupaten =
        (kodeKabupatenIndex != -1 && row.length > kodeKabupatenIndex)
            ? row[kodeKabupatenIndex].trim()
            : '';

        final kodeProvinsi =
        (kodeProvinsiIndex != -1 && row.length > kodeProvinsiIndex)
            ? row[kodeProvinsiIndex].trim()
            : '';

        items.add(
          JatimLocationItem(
            kodeKecamatan: kodeKecamatan,
            kecamatan: _toTitleCase(kecamatan),
            kodeKabupaten: kodeKabupaten,
            kabupaten: _toTitleCase(kabupaten),
            kodeProvinsi: kodeProvinsi,
            provinsi: _toTitleCase(provinsi),
          ),
        );
      }

      setState(() {
        _allLocations
          ..clear()
          ..addAll(items);
        _filteredLocations = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat dataset lokasi: $e')),
      );
    }
  }

  String _normalizeHeader(String value) {
    return value
        .replaceFirst('\uFEFF', '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[ /]+'), '_');
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      _runSearch(_searchController.text);
    });
  }

  void _runSearch(String query) {
    final normalizedQuery = _normalize(query);

    if (normalizedQuery.isEmpty) {
      setState(() {
        _filteredLocations = [];
      });
      return;
    }

    final scored = _allLocations
        .map((item) => MapEntry(item, _calculateScore(item, normalizedQuery)))
        .where((entry) => entry.value > 0)
        .toList();

    scored.sort((a, b) {
      final scoreCompare = b.value.compareTo(a.value);
      if (scoreCompare != 0) return scoreCompare;
      return a.key.kecamatan.compareTo(b.key.kecamatan);
    });

    setState(() {
      _filteredLocations = scored.take(20).map((e) => e.key).toList();
    });
  }

  int _calculateScore(JatimLocationItem item, String query) {
    final kecamatan = _normalize(item.kecamatan);
    final kabupaten = _normalize(item.kabupaten);
    final provinsi = _normalize(item.provinsi);
    final full = '$kecamatan $kabupaten $provinsi';

    int score = 0;

    if (kecamatan == query) score += 1000;
    if (kabupaten == query) score += 900;
    if (provinsi == query) score += 800;

    if (kecamatan.startsWith(query)) score += 700;
    if (kabupaten.startsWith(query)) score += 550;
    if (provinsi.startsWith(query)) score += 450;

    if (kecamatan.contains(query)) score += 300;
    if (kabupaten.contains(query)) score += 220;
    if (provinsi.contains(query)) score += 140;
    if (full.contains(query)) score += 80;

    return score;
  }

  String _normalize(String value) {
    return value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _toTitleCase(String value) {
    final lower = value.toLowerCase();
    return lower
        .split(' ')
        .map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    })
        .join(' ');
  }

  Future<void> _selectLocation(JatimLocationItem item) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await AuthService.instance.saveUserLocation(
        latitude: null,
        longitude: null,
        city: item.kecamatan,
        regency: item.kabupaten,
        province: item.provinsi,
        source: 'manual',
      );

      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
        return;
      }

      Navigator.pop(
        context,
        {
          'city': item.kecamatan,
          'regency': item.kabupaten,
          'province': item.provinsi,
          'kode_kecamatan': item.kodeKecamatan,
          'kode_kabupaten': item.kodeKabupaten,
          'kode_provinsi': item.kodeProvinsi,
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildSuggestionItem(JatimLocationItem item) {
    return InkWell(
      onTap: _isSaving ? null : () => _selectLocation(item),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.kecamatan,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.kabupaten}, ${item.provinsi}',
                    style: const TextStyle(
                      color: _textSecondary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(left: 12, top: 4),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchText = _searchController.text.trim();
    final iconColor = searchText.isNotEmpty ? _blue : _textHint;

    return Scaffold(
      backgroundColor: _whiteBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: _textPrimary,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Cari Lokasi Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _textPrimary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                cursorColor: _blue,
                style: const TextStyle(
                  color: _blue,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan lokasi Anda disini',
                  hintStyle: const TextStyle(
                    color: _textHint,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: iconColor,
                    size: 20,
                  ),
                  suffixIcon: searchText.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _runSearch('');
                    },
                    icon: const Icon(
                      Icons.close,
                      color: _textHint,
                      size: 18,
                    ),
                  )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: _borderGray,
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
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : searchText.isEmpty
                    ? const Center(
                  child: Text(
                    'Ketik kecamatan, kabupaten/kota, atau provinsi\nuntuk melihat rekomendasi lokasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textSecondary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                )
                    : _filteredLocations.isEmpty
                    ? const Center(
                  child: Text(
                    'Tidak ada lokasi yang cocok.',
                    style: TextStyle(
                      color: _textSecondary,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hasil Pencarian',
                      style: TextStyle(
                        color: _textSecondary,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _filteredLocations.length,
                        separatorBuilder: (_, _) =>
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: _dividerColor,
                        ),
                        itemBuilder: (context, index) {
                          final item = _filteredLocations[index];
                          return _buildSuggestionItem(item);
                        },
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

class JatimLocationItem {
  final String kodeKecamatan;
  final String kecamatan;
  final String kodeKabupaten;
  final String kabupaten;
  final String kodeProvinsi;
  final String provinsi;

  const JatimLocationItem({
    required this.kodeKecamatan,
    required this.kecamatan,
    required this.kodeKabupaten,
    required this.kabupaten,
    required this.kodeProvinsi,
    required this.provinsi,
  });

  String get fullLabel => '$kecamatan, $kabupaten, $provinsi';
}