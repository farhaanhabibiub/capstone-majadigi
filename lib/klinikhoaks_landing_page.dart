import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'klinikhoaks_model.dart';

class KlinikHoaksLandingPage extends StatefulWidget {
  const KlinikHoaksLandingPage({super.key});

  @override
  State<KlinikHoaksLandingPage> createState() => _KlinikHoaksLandingPageState();
}

class _KlinikHoaksLandingPageState extends State<KlinikHoaksLandingPage> {
  static const _blue = Color(0xFF007AFF);

  final _topikController = TextEditingController();
  final _isiController = TextEditingController();
  final _linkController = TextEditingController();

  PlatformFile? _pickedFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _topikController.dispose();
    _isiController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  bool get _isLinkValid {
    final link = _linkController.text.trim();
    return link.startsWith('http://') || link.startsWith('https://');
  }

  bool get _isFormFilled =>
      _topikController.text.isNotEmpty &&
      _isiController.text.isNotEmpty &&
      _isLinkValid;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'mp4', 'mov'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<String> _uploadFile(String tiketId) async {
    if (_pickedFile == null || _pickedFile!.path == null) return '';
    final file = File(_pickedFile!.path!);
    final ref = FirebaseStorage.instance
        .ref()
        .child('laporan_hoaks/$tiketId/${_pickedFile!.name}');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_isFormFilled || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan login terlebih dahulu')),
        );
      }
      return;
    }

    final tiketId = LaporanHoaks.generateTiketId();

    try {
      final fileUrl = await _uploadFile(tiketId);

      final laporan = LaporanHoaks(
        uid: user.uid,
        namaUser: user.displayName ?? '',
        tiketId: tiketId,
        topik: _topikController.text.trim(),
        isiLaporan: _isiController.text.trim(),
        linkBukti: _linkController.text.trim(),
        namaFile: _pickedFile?.name ?? '',
        fileUrl: fileUrl,
        status: 'Diproses',
        tanggal: LaporanHoaks.formatTanggal(DateTime.now()),
      );

      final col = FirebaseFirestore.instance.collection('laporan_hoaks');
      final docRef = await col.add(laporan.toMap());
      final saved = LaporanHoaks.fromMap(laporan.toMap(), docId: docRef.id);

      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF27AE60),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Laporan Terkirim!',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nomor Tiket Anda:',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF5FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    saved.tiketId,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _blue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pantau status verifikasi di tab\n"Tiket Saya"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, saved);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: _blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim laporan. Coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF007AFF), Color(0xFF0062D1)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Text(
                          'Permohonan Klarifikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Topik'),
                          _buildTextField(
                            controller: _topikController,
                            hint: 'Contoh: Hoaks Bansos, Penipuan CPNS...',
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('Isi Laporan'),
                          _buildTextField(
                            controller: _isiController,
                            hint:
                                'Jelaskan informasi yang ingin diklarifikasi...',
                            maxLines: 5,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('Link Bukti / Alamat Website'),
                          _buildTextField(
                            controller: _linkController,
                            hint: 'https://',
                            onChanged: (_) => setState(() {}),
                          ),
                          if (_linkController.text.isNotEmpty && !_isLinkValid)
                            const Padding(
                              padding: EdgeInsets.only(top: 6, left: 4),
                              child: Text(
                                'Link harus diawali dengan https:// atau http://',
                                style: TextStyle(
                                  color: Color(0xFFE52B44),
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          _buildLabel('Bukti File (opsional)'),
                          if (_pickedFile != null) _buildSelectedFile(),
                          _buildFilePickerButton(),
                          const SizedBox(height: 40),
                          _buildSubmitButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'PlusJakartaSans',
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _blue, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: _blue, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _pickedFile!.name,
              style: const TextStyle(
                color: _blue,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _pickedFile = null),
            child: const Icon(Icons.close, color: Colors.grey, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePickerButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              _pickedFile == null ? 'Pilih File' : 'Ganti File',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'JPG, PNG, PDF, MP4 — maks 10MB',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final enabled = _isFormFilled && !_isSubmitting;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? _blue : const Color(0xFFD1D5DB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Ajukan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PlusJakartaSans',
                  color: enabled ? Colors.white : Colors.white70,
                ),
              ),
      ),
    );
  }
}
