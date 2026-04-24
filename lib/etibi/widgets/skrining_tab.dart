import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/etibi_model.dart';

class SkriningTab extends StatefulWidget {
  final Function(RiwayatSkrining) onSubmit;
  final VoidCallback onSelesai;

  const SkriningTab({super.key, required this.onSubmit, required this.onSelesai});

  @override
  State<SkriningTab> createState() => _SkriningTabState();
}

class _SkriningTabState extends State<SkriningTab> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  int _currentFormStep = 0;

  // Step 0 Data
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();

  // Step 1 Data
  String? _jenisKelamin;
  String? _tahunLahir;
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _bbController = TextEditingController();
  final TextEditingController _tbController = TextEditingController();

  // Step 2 Data
  final TextEditingController _alamatController = TextEditingController();
  String? _pekerjaan;
  final TextEditingController _kotaController = TextEditingController();

  // Step 3 Data (radio buttons: true = Ya, false = Tidak, null = unset)
  final Map<int, bool?> _jawabanSkrining = {};
  
  static const List<String> _pertanyaanList = [
    'Batuk lebih dari 2 minggu',
    'Demam',
    'Berkeringat malam hari tanpa aktivitas',
    'Sesak nafas',
    'Nyeri dada',
    'Ada benjolan di leher/bawah rahang/bawah telinga/ketiak',
    'Batuk berdarah',
    'Batuk kurang dari 2 minggu',
    'Nafsu makan turun (atau hilang nafsu makan selama berhari-hari)',
    'Mudah lelah (atau sering kecapekan tanpa aktivitas fisik yang berarti)',
    'Berat badan turun (turun drastis selama berhari-hari bukan karena diet)',
    'Anggota keluarga serumah ada yang sakit TBC ?',
    'Pernah berada satu ruangan dengan penderita TBC (di kantor, tempat kerja/ kelas/ kamar/ asrama/ panti/ barak, dll) ?',
    'Apakah pernah tinggal serumah minimal satu malam atau sering tinggal serumah pada siang hari dengan orang yang sakit TBC ?',
    'Pernah Berobat TBC tuntas',
    'Pernah Berobat TBC tapi tidak tuntas',
    'Punya riwayat diabetes melitus / kencing manis',
    'Orang Dengan HIV',
    'Ibu Hamil',
    'Merokok',
    'Usia 0-14 tahun',
    'Kurang Gizi (kurus)',
    'Lansia (diatas 60 tahun)',
  ];

  // Hasil skrining
  int _skorAkhir = 0;
  String _levelRisiko = 'Rendah';
  RiwayatSkrining? _pendingRiwayat; // disimpan setelah hitung, dikirim saat Selesai
  // Skor per kategori
  int _skorGejalaUtama = 0;
  int _skorGejalaPendukung = 0;
  int _skorRiwayatKontak = 0;
  int _skorFaktorRisiko = 0;

  static const int _skorMax = 46;
  static const int _maxGejalaUtama = 11;
  static const int _maxGejalaPendukung = 11;
  static const int _maxRiwayatKontak = 13;
  static const int _maxFaktorRisiko = 11;

  // Bobot tiap pertanyaan (index sesuai _pertanyaanList)
  static const Map<int, int> _bobot = {
    0: 3,  // Batuk > 2 minggu
    1: 2,  // Demam
    2: 2,  // Keringat malam
    3: 2,  // Sesak nafas
    4: 1,  // Nyeri dada
    5: 2,  // Benjolan leher/ketiak
    6: 5,  // Batuk berdarah
    7: 1,  // Batuk < 2 minggu
    8: 1,  // Nafsu makan turun
    9: 1,  // Mudah lelah
    10: 2, // BB turun
    11: 3, // Keluarga serumah TBC
    12: 2, // Satu ruangan penderita TBC
    13: 3, // Pernah tinggal serumah penderita TBC
    14: 2, // TBC tuntas
    15: 3, // TBC tidak tuntas
    16: 2, // Diabetes melitus
    17: 3, // HIV
    18: 1, // Ibu hamil
    19: 1, // Merokok
    20: 1, // Usia 0-14
    21: 2, // Kurang gizi
    22: 1, // Lansia
  };

  static const Set<int> _idxGejalaUtama      = {0, 3, 4, 6};
  static const Set<int> _idxGejalaPendukung  = {1, 2, 5, 7, 8, 9, 10};
  static const Set<int> _idxRiwayatKontak    = {11, 12, 13, 14, 15};
  static const Set<int> _idxFaktorRisiko     = {16, 17, 18, 19, 20, 21, 22};

  @override
  void initState() {
    super.initState();
    // Pre-fill nama dari akun yang sedang login
    final displayName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    if (displayName.isNotEmpty) _namaController.text = displayName;
    _namaController.addListener(_onTextChanged);
    _nikController.addListener(_onTextChanged);
    _noTelpController.addListener(_onTextChanged);
    _bbController.addListener(_onTextChanged);
    _tbController.addListener(_onTextChanged);
    _alamatController.addListener(_onTextChanged);
    _kotaController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _noTelpController.dispose();
    _bbController.dispose();
    _tbController.dispose();
    _alamatController.dispose();
    _kotaController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to re-evaluate button state
  }

  bool get _isStep0Valid {
    final nik = _nikController.text.trim();
    return _namaController.text.trim().isNotEmpty && nik.length == 16 && double.tryParse(nik) != null;
  }

  bool get _isStep1Valid {
    return _jenisKelamin != null &&
           _tahunLahir != null &&
           _noTelpController.text.trim().isNotEmpty &&
           _bbController.text.trim().isNotEmpty &&
           _tbController.text.trim().isNotEmpty;
  }

  bool get _isStep2Valid {
    return _alamatController.text.trim().isNotEmpty &&
           _pekerjaan != null &&
           _kotaController.text.trim().isNotEmpty;
  }

  bool get _isStep3Valid {
    return _jawabanSkrining.length == _pertanyaanList.length;
  }

  void _nextStep() {
    setState(() {
      _currentFormStep++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentFormStep > 0) _currentFormStep--;
    });
  }

  void _hitungHasilSkrining(Map<int, bool?> jawaban) {
    int gu = 0, gp = 0, rk = 0, fr = 0;

    jawaban.forEach((idx, ya) {
      if (ya != true) return;
      final bobot = _bobot[idx] ?? 0;
      if (_idxGejalaUtama.contains(idx))     gu += bobot;
      if (_idxGejalaPendukung.contains(idx)) gp += bobot;
      if (_idxRiwayatKontak.contains(idx))   rk += bobot;
      if (_idxFaktorRisiko.contains(idx))    fr += bobot;
    });

    final total = gu + gp + rk + fr;

    String level;
    // Batuk berdarah langsung Tinggi
    if (jawaban[6] == true) {
      level = 'Tinggi';
    } else if (total >= 13) {
      level = 'Tinggi';
    } else if (total >= 6) {
      level = 'Sedang';
    } else {
      level = 'Rendah';
    }

    _skorAkhir          = total;
    _levelRisiko        = level;
    _skorGejalaUtama    = gu;
    _skorGejalaPendukung = gp;
    _skorRiwayatKontak  = rk;
    _skorFaktorRisiko   = fr;
  }

  void _submitForm() {
    _hitungHasilSkrining(_jawabanSkrining);

    String tanggal;
    try {
      tanggal = DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now());
    } catch (e) {
      const months = ['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
      final now = DateTime.now();
      tanggal = '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';
    }

    // Simpan dulu, baru dikirim ke parent saat "Selesai" diklik
    _pendingRiwayat = RiwayatSkrining(
      tanggal: tanggal,
      hasil: 'Risiko $_levelRisiko',
      levelRisiko: _levelRisiko,
      skor: _skorAkhir,
      skorMax: _skorMax,
      faskes: '-',
      kabupaten: _kotaController.text.trim(),
      noTelp: _noTelpController.text.trim(),
    );

    _nextStep();
  }

  void _resetForm() {
    // Kirim hasil ke parent (simpan ke list + Firestore) tepat saat Selesai diklik
    if (_pendingRiwayat != null) {
      widget.onSubmit(_pendingRiwayat!);
      _pendingRiwayat = null;
    }

    final displayName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    setState(() {
      _currentFormStep = 0;
      _namaController.text = displayName;
      _nikController.clear();
      _jenisKelamin = null;
      _tahunLahir = null;
      _noTelpController.clear();
      _bbController.clear();
      _tbController.clear();
      _alamatController.clear();
      _pekerjaan = null;
      _kotaController.clear();
      _jawabanSkrining.clear();
    });

    widget.onSelesai();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentFormStep < 4) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color.fromRGBO(0, 101, 255, 0.1),
                  child: const Icon(Icons.person, color: _blue, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentFormStep == 3 ? 'Keluhan yang dirasakan' : (_currentFormStep == 0 ? 'Identitas Awal' : 'Detail Identitas'),
                        style: const TextStyle(
                          color: _textPrimary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentFormStep == 3 ? 'Mulai skrining yuk!' : 'Lengkapi data sesuai identitas asli',
                        style: const TextStyle(
                          color: _textSecondary,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          _buildFormContent(),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    switch (_currentFormStep) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return _buildStep0();
    }
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Nama Lengkap'),
        _buildTextField(_namaController, 'Masukkan Nama Lengkap'),
        const SizedBox(height: 16),
        _buildLabel('NIK'),
        _buildTextField(_nikController, 'Masukkan NIK', isNumber: true),
        const Padding(
          padding: EdgeInsets.only(top: 8, left: 4),
          child: Text('NIK harus 16 digit angka', style: TextStyle(fontSize: 11, color: _textSecondary, fontFamily: 'PlusJakartaSans')),
        ),
        const SizedBox(height: 24),
        _buildButton('Selanjutnya', _isStep0Valid ? _nextStep : null, isPrimary: true),
      ],
    );
  }

  Widget _buildStep1() {
    final List<String> currentYears = List.generate(100, (index) => (DateTime.now().year - index).toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Jenis Kelamin'),
        _buildDropdown('Pilih jenis kelamin', ['Laki-laki', 'Perempuan'], _jenisKelamin, (v) => setState(() => _jenisKelamin = v)),
        const SizedBox(height: 16),
        _buildLabel('Tahun Lahir'),
        _buildDropdown('Pilih tahun kelahiran', currentYears, _tahunLahir, (v) => setState(() => _tahunLahir = v)),
        const SizedBox(height: 16),
        _buildLabel('No. Telp'),
        _buildTextField(_noTelpController, 'Masukkan nomor telepon', isNumber: true),
        const SizedBox(height: 16),
        _buildLabel('Berat Badan'),
        _buildTextField(_bbController, 'xx', suffix: 'kg', isNumber: true),
        const SizedBox(height: 16),
        _buildLabel('Tinggi Badan'),
        _buildTextField(_tbController, 'xxx', suffix: 'cm', isNumber: true),
        const SizedBox(height: 24),
        _buildButton('Sebelumnya', _prevStep, isPrimary: false),
        const SizedBox(height: 12),
        _buildButton('Selanjutnya', _isStep1Valid ? _nextStep : null, isPrimary: true),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Alamat Domisili'),
        _buildTextField(_alamatController, 'Jl. Bunga No. 27, Kecamatan Sukun'),
        const SizedBox(height: 16),
        _buildLabel('Pekerjaan'),
        _buildDropdown('Pilih pekerjaan', [
          'Tenaga Profesional Medis',
          'Mahasiswa',
          'Karyawan',
          'PNS',
          'Petani',
          'Tenaga Profesional Non Medis',
          'Tidak Bekerja',
          'Tidak Diketahui',
          'TNI/Polri',
          'Warga Binaan Pemasyarakatan',
          'Wiraswasta',
          'Asisten Rumah Tangga',
          'Lain-lain'
        ], _pekerjaan, (v) => setState(() => _pekerjaan = v)),
        const SizedBox(height: 16),
        _buildLabel('Kabupaten/Kota'),
        _buildTextField(_kotaController, 'Kota Malang'),
        const SizedBox(height: 24),
        _buildButton('Sebelumnya', _prevStep, isPrimary: false),
        const SizedBox(height: 12),
        _buildButton('Selanjutnya', _isStep2Valid ? _nextStep : null, isPrimary: true),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._pertanyaanList.asMap().entries.map((entry) {
          int index = entry.key;
          String question = entry.value;

          Widget questionWidget = _buildRadioQuestion(question, _jawabanSkrining[index], (v) => setState(() => _jawabanSkrining[index] = v));

          if (index == 11) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Informasi Lainnya',
                  style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                questionWidget,
              ],
            );
          }

          return questionWidget;
        }),
        const SizedBox(height: 24),
        _buildButton('Sebelumnya', _prevStep, isPrimary: false),
        const SizedBox(height: 12),
        _buildButton('Submit Data', _isStep3Valid ? _submitForm : null, isPrimary: true),
      ],
    );
  }

  Widget _buildStep4() {
    final Color levelColor = _levelRisiko == 'Tinggi'
        ? const Color(0xFFD32F2F)
        : _levelRisiko == 'Sedang'
            ? const Color(0xFFF59E0B)
            : const Color(0xFF2E7D32);
    final Color levelBg = _levelRisiko == 'Tinggi'
        ? const Color(0xFFFFEBEE)
        : _levelRisiko == 'Sedang'
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFE8F5E9);
    final IconData levelIcon = _levelRisiko == 'Tinggi'
        ? Icons.warning_amber_rounded
        : _levelRisiko == 'Sedang'
            ? Icons.info_outline_rounded
            : Icons.check_circle_outline;

    final String rekomendasiText = _levelRisiko == 'Tinggi'
        ? 'Segera periksakan diri ke Puskesmas atau fasilitas kesehatan terdekat. Jangan tunda, deteksi dini sangat penting.'
        : _levelRisiko == 'Sedang'
            ? 'Disarankan untuk berkonsultasi dengan dokter atau tenaga kesehatan untuk pemeriksaan lanjutan.'
            : 'Tidak ditemukan indikasi risiko tinggi. Tetap jaga kesehatan dan periksakan diri jika keluhan berlanjut.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Level Badge ──────────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: levelBg, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: levelColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(levelIcon, color: levelColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risiko $_levelRisiko',
                      style: TextStyle(color: levelColor, fontFamily: 'PlusJakartaSans', fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rekomendasiText,
                      style: TextStyle(color: levelColor.withValues(alpha: 0.85), fontFamily: 'PlusJakartaSans', fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Skor Total ───────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Skor Total Risiko', style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '$_skorAkhir',
                    style: TextStyle(color: levelColor, fontFamily: 'PlusJakartaSans', fontSize: 36, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    ' / $_skorMax',
                    style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  _levelPill('≤ 5', 'Rendah', const Color(0xFF2E7D32), _levelRisiko == 'Rendah'),
                  const SizedBox(width: 6),
                  _levelPill('6–12', 'Sedang', const Color(0xFFF59E0B), _levelRisiko == 'Sedang'),
                  const SizedBox(width: 6),
                  _levelPill('≥ 13', 'Tinggi', const Color(0xFFD32F2F), _levelRisiko == 'Tinggi'),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (_skorAkhir / _skorMax).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: const Color(0xFFF0F0F0),
                  valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Breakdown per Kategori ───────────────────────────────────────────────
        const Text('Detail per Kategori', style: TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _kategoriRow(Icons.coronavirus_outlined,     'Gejala Utama',       _skorGejalaUtama,    _maxGejalaUtama,    const Color(0xFFD32F2F)),
        const SizedBox(height: 8),
        _kategoriRow(Icons.sick_outlined,             'Gejala Pendukung',   _skorGejalaPendukung,_maxGejalaPendukung,const Color(0xFFF59E0B)),
        const SizedBox(height: 8),
        _kategoriRow(Icons.people_outline,            'Riwayat & Kontak',   _skorRiwayatKontak,  _maxRiwayatKontak,  const Color(0xFF7C3AED)),
        const SizedBox(height: 8),
        _kategoriRow(Icons.health_and_safety_outlined,'Faktor Risiko',      _skorFaktorRisiko,   _maxFaktorRisiko,   const Color(0xFF0284C7)),

        const SizedBox(height: 20),

        // ── Disclaimer ───────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: _blue, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Hasil skrining ini bersifat indikatif dan bukan diagnosis medis. Konfirmasi diagnosis hanya dapat dilakukan oleh tenaga kesehatan.',
                  style: TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 11, height: 1.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildButton('Selesai', _resetForm, isPrimary: true),
      ],
    );
  }

  Widget _levelPill(String range, String label, Color color, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? color : const Color(0xFFDDDDDD)),
      ),
      child: Column(
        children: [
          Text(range, style: TextStyle(color: active ? Colors.white : _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 9, fontWeight: FontWeight.w600)),
          Text(label, style: TextStyle(color: active ? Colors.white : _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 9)),
        ],
      ),
    );
  }

  Widget _kategoriRow(IconData icon, String label, int skor, int max, Color color) {
    final double pct = max > 0 ? skor / max : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('$skor / $max', style: TextStyle(color: color, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {String? suffix, bool isNumber = false}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _blue, width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
           Expanded(
            child: TextField(
              controller: controller,
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              style: const TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'PlusJakartaSans'),
              ),
            ),
           ),
           if (suffix != null) ...[
             Text(suffix, style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 14)),
           ]
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _blue, width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'PlusJakartaSans', fontSize: 14)),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: _textSecondary),
          style: const TextStyle(color: _blue, fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w500),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRadioQuestion(String question, bool? groupValue, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: groupValue == true ? _blue : Colors.white,
                      border: Border.all(color: _blue, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text('Ya', style: TextStyle(color: groupValue == true ? Colors.white : _blue, fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: groupValue == false ? _blue : Colors.white,
                      border: Border.all(color: _blue, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text('Tidak', style: TextStyle(color: groupValue == false ? Colors.white : _blue, fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed, {required bool isPrimary}) {
    final bool isEnabled = onPressed != null;

    final Color bgColor = isPrimary 
         ? (isEnabled ? _blue : Colors.grey.shade300)
         : Colors.transparent;

    final Color textColor = isPrimary 
         ? (isEnabled ? Colors.white : Colors.grey.shade500)
         : (isEnabled ? _blue : Colors.grey.shade400);

    final BorderSide borderSide = isPrimary
         ? BorderSide.none
         : BorderSide(color: isEnabled ? _blue : Colors.grey.shade400, width: 1.5);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: Text(text, style: TextStyle(color: textColor, fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w600)),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: borderSide,
                disabledForegroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text(text, style: TextStyle(color: textColor, fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w600)),
            ),
    );
  }
}
