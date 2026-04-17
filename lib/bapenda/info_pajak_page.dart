import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_route.dart';
import 'hasil_pajak_page.dart';

class InfoPajakPage extends StatefulWidget {
  const InfoPajakPage({super.key});

  @override
  State<InfoPajakPage> createState() => _InfoPajakPageState();
}

class _InfoPajakPageState extends State<InfoPajakPage> {
  final TextEditingController _platController = TextEditingController();
  final TextEditingController _rangkaController = TextEditingController();

  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);
  static const Color _textHint = Color.fromRGBO(180, 180, 180, 1);

  // CSV data dimuat sekali
  List<KendaraanData> _database = [];
  bool _dbLoaded = false;
  bool _isSearching = false;

  bool get _isFormFilled =>
      _platController.text.trim().isNotEmpty &&
      _rangkaController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _platController.addListener(_refresh);
    _rangkaController.addListener(_refresh);
    _loadDatabase();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _platController.removeListener(_refresh);
    _rangkaController.removeListener(_refresh);
    _platController.dispose();
    _rangkaController.dispose();
    super.dispose();
  }

  Future<void> _loadDatabase() async {
    try {
      final raw = await rootBundle.loadString('assets/data/kendaraan_dummy.csv');
      final rows = const CsvToListConverter(
        fieldDelimiter: ',',
        shouldParseNumbers: false,
        eol: '\n',
      ).convert(raw);

      if (rows.length <= 1) return;

      final items = <KendaraanData>[];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 16) continue;
        items.add(KendaraanData.fromCsvRow(row));
      }

      if (mounted) {
        setState(() {
          _database = items;
          _dbLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _dbLoaded = true);
    }
  }

  void _handleCari() {
    FocusScope.of(context).unfocus();

    if (!_dbLoaded) {
      _showErrorAlert('Database belum selesai dimuat. Coba lagi sebentar.');
      return;
    }

    setState(() => _isSearching = true);

    final inputPlat = _platController.text.trim().toUpperCase();
    final inputRangka = _rangkaController.text.trim().toUpperCase();

    KendaraanData? found;
    for (final item in _database) {
      if (item.platNomor.toUpperCase() == inputPlat &&
          item.nomorRangka.toUpperCase() == inputRangka) {
        found = item;
        break;
      }
    }

    setState(() => _isSearching = false);

    if (found == null) {
      _showErrorAlert(
        'Data kendaraan tidak ditemukan.\nPeriksa kembali plat nomor dan nomor rangka Anda.',
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.hasilPajakPage,
      arguments: found,
    );
  }

  void _showErrorAlert(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color.fromRGBO(220, 38, 38, 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Informasi PKB',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Kartu Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(235, 243, 255, 1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: _blue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cek Pajak Kendaraan',
                        style: TextStyle(
                          color: _textPrimary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'BAPENDA Provinsi Jawa Timur',
                        style: TextStyle(
                          color: _textSecondary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Plat Nomor ────────────────────────────────────────────────
            const Text(
              'Plat Nomor Kendaraan',
              style: TextStyle(
                color: _textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _platController,
              hint: 'X 0000 XX',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                UpperCaseTextFormatter(),
              ],
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 18),

            // ── Nomor Rangka ──────────────────────────────────────────────
            const Text(
              '5 Digit Terakhir Nomor Rangka',
              style: TextStyle(
                color: _textPrimary,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _rangkaController,
              hint: '12345',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(5),
                UpperCaseTextFormatter(),
              ],
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 28),

            // ── Tombol ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isFormFilled && !_isSearching) ? _handleCari : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  disabledBackgroundColor: const Color.fromRGBO(210, 210, 210, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: _isSearching
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Cari Data Kendaraan',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required TextInputAction textInputAction,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final bool isFilled = controller.text.trim().isNotEmpty;
    final Color borderColor =
        isFilled ? _blue : const Color.fromRGBO(225, 225, 225, 1);

    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: isFilled ? _blue : _textPrimary,
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _textHint,
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: _blue, width: 1.4),
        ),
      ),
    );
  }
}

// Formatter untuk otomatis uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
