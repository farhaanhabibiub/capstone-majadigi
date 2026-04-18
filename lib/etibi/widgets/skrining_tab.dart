import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/etibi_model.dart';

class SkriningTab extends StatefulWidget {
  final Function(RiwayatSkrining) onSubmit;

  const SkriningTab({Key? key, required this.onSubmit}) : super(key: key);

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

  // For final result state
  bool _isTerindikasi = false;

  @override
  void initState() {
    super.initState();
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

  String _hitungHasilSkrining(Map<int, bool?> jawaban) {
    // 1. CEK GEJALA UTAMA
    // Index 0: Batuk > 2 mgg, Index 6: Batuk berdarah
    bool adaGejalaUtama = 
    (jawaban[0] == true) || 
    (jawaban[3] == true) || 
    (jawaban[6] == true);

    // 2. HITUNG GEJALA MINOR
    int minorCount = 0;
    final List<int> gejalaMinorIndices = [1, 2, 4, 5, 7, 8, 9, 10];
    
    for (int idx in gejalaMinorIndices) {
      if (jawaban[idx] == true) {
        minorCount++;
      }
    }

    // 3. LOGIKA KEPUTUSAN FINAL (Kombinasi)
    if (adaGejalaUtama && minorCount >= 2) {
      // Punya batuk parah + dibarengi gejala lain (misal: demam)
      return 'Terindikasi TBC';
    } else if (minorCount >= 4) {
      // Tidak ada batuk parah, tapi keluhan minor numpuk (misal: demam + lelah + BB turun)
      return 'Terindikasi TBC';
    } else {
      // Cuma batuk doang tanpa gejala lain, atau cuma demam doang
      return 'Tidak Terindikasi TBC';
    }
  }

  void _submitForm() {
    String hasilAkhir = _hitungHasilSkrining(_jawabanSkrining);
    _isTerindikasi = (hasilAkhir == 'Terindikasi TBC');

    String tanggal;
    try {
      tanggal = DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now());
    } catch (e) {
      final List<String> months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      final now = DateTime.now();
      tanggal = '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';
    }

    final riwayatBaru = RiwayatSkrining(
      tanggal: tanggal,
      hasil: hasilAkhir,
      faskes: '-',
      kabupaten: _kotaController.text.trim(),
      noTelp: _noTelpController.text.trim(),
    );

    widget.onSubmit(riwayatBaru);
    _nextStep(); // Go to Step 4
  }

  void _resetForm() {
    setState(() {
      _currentFormStep = 0;
      _namaController.clear();
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
        }).toList(),
        const SizedBox(height: 24),
        _buildButton('Sebelumnya', _prevStep, isPrimary: false),
        const SizedBox(height: 12),
        _buildButton('Submit Data', _isStep3Valid ? _submitForm : null, isPrimary: true),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Icon(_isTerindikasi ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: _isTerindikasi ? const Color(0xFFD32F2F) : _blue, size: 40),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                       Text(
                         _isTerindikasi 
                            ? 'Anda menunjukkan gejala TBC. Segera periksakan diri ke fasilitas kesehatan terdekat.' 
                            : 'Anda tidak menunjukkan gejala TBC. Tetap waspada, dan periksakan diri bila ada keluhan.',
                         style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary),
                       ),
                       const SizedBox(height: 8),
                       const Text(
                         'Kunjungi Puskesmas atau faskes terdekat untuk mendeteksi kemungkinan adanya penyakit lain.',
                         style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, color: _textSecondary),
                       ),
                   ],
                 )
               )
             ]
          )
        ),
        const SizedBox(height: 32),
        _buildButton('Selesai', _resetForm, isPrimary: true),
      ],
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
