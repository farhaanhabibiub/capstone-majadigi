import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../app_transitions.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton_loader.dart';

class UbahProfilPage extends StatefulWidget {
  const UbahProfilPage({super.key});

  @override
  State<UbahProfilPage> createState() => _UbahProfilPageState();
}

class _UbahProfilPageState extends State<UbahProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _email = '';
  String _photoUrl = '';
  File? _pickedFile;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _email = user.email ?? '';
    _nameCtrl.text = user.displayName ?? '';
    _photoUrl = user.photoURL ?? '';

    // Load phone from Firestore
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final phone = doc.data()?['phone'] as String? ?? '';
      // Strip +62 or leading 0 so user sees only the local digits
      String local = phone;
      if (local.startsWith('+62')) {
        local = local.substring(3);
      } else if (local.startsWith('0')) {
        local = local.substring(1);
      }
      _phoneCtrl.text = local;
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickPhoto() async {
    final source = await _showSourceSheet();
    if (source == null) return;

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 1024,
    );
    if (file == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Sesuaikan Foto',
          toolbarColor: AppTheme.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppTheme.primary,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: false,
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: 'Sesuaikan Foto',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          cropStyle: CropStyle.circle,
        ),
      ],
    );

    if (cropped != null && mounted) {
      setState(() => _pickedFile = File(cropped.path));
    }
  }

  Future<ImageSource?> _showSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Ubah Foto Profil',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primary),
              title: const Text(
                'Ambil dari Kamera',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primary),
              title: const Text(
                'Pilih dari Galeri',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadPhoto(User user) async {
    if (_pickedFile == null) return null;
    try {
      final ref = FirebaseStorage.instance
          .ref('profile_photos/${user.uid}.jpg');
      await ref.putFile(_pickedFile!);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { setState(() => _isSaving = false); return; }

    try {
      // 1. Upload foto jika ada yang baru
      final newPhotoUrl = await _uploadPhoto(user);

      // 2. Update Firebase Auth
      await user.updateDisplayName(_nameCtrl.text.trim());
      if (newPhotoUrl != null) await user.updatePhotoURL(newPhotoUrl);

      // 3. Update Firestore
      final phone = _phoneCtrl.text.trim();
      final fullPhone = phone.isEmpty ? '' : '+62$phone';
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': _nameCtrl.text.trim(),
        'phone': fullPhone,
        'photoUrl': ?newPhotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Profil berhasil diperbarui', style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w500, color: Colors.white)),
              ],
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan. Coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
        title: const Text(
          'Ubah Profil',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? SkeletonLoader.form(fieldCount: 3)
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Avatar ─────────────────────────────────────────────
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Hero(
                            tag: HeroTags.profileAvatar,
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: const Color.fromRGBO(220, 232, 255, 1),
                              backgroundImage: _pickedFile != null
                                  ? FileImage(_pickedFile!)
                                  : (_photoUrl.isNotEmpty
                                      ? NetworkImage(_photoUrl) as ImageProvider
                                      : null),
                              child: (_pickedFile == null && _photoUrl.isEmpty)
                                  ? Image.asset(
                                      'assets/images/avatar_placeholder.png',
                                      width: 104,
                                      height: 104,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.person_rounded,
                                        color: AppTheme.primary,
                                        size: 52,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      'Ketuk foto untuk mengubah & memotong',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Form ───────────────────────────────────────────────
                    _buildCard(
                      children: [
                        _fieldLabel('Nama Lengkap'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                          decoration: _inputDeco('Masukkan nama lengkap'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nama tidak boleh kosong'
                              : null,
                        ),

                        const SizedBox(height: 18),

                        _fieldLabel('Email'),
                        const SizedBox(height: 6),
                        TextFormField(
                          initialValue: _email,
                          readOnly: true,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          decoration: _inputDeco('Email').copyWith(
                            filled: true,
                            fillColor: const Color.fromRGBO(245, 245, 245, 1),
                            suffixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Email tidak dapat diubah',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _fieldLabel('Nomor HP'),
                        const SizedBox(height: 6),
                        _buildPhoneField(),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Tombol Simpan ──────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          disabledBackgroundColor: const Color.fromRGBO(210, 210, 210, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontFamily: AppTheme.fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPhoneField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // +62 prefix
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(245, 245, 245, 1),
            border: Border.all(color: const Color.fromRGBO(210, 210, 210, 1)),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          alignment: Alignment.center,
          child: const Text(
            '+62',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        // Phone number input
        Expanded(
          child: TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '8xxxxxxxxxx',
              hintStyle: const TextStyle(
                color: Color.fromRGBO(180, 180, 180, 1),
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                borderSide: BorderSide(color: Color.fromRGBO(210, 210, 210, 1)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                borderSide: BorderSide(color: AppTheme.danger),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                borderSide: BorderSide(color: AppTheme.danger, width: 1.5),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null; // boleh kosong
              if (v.trim().length < 7) return 'Nomor HP tidak valid';
              return null;
            },
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color.fromRGBO(180, 180, 180, 1),
        fontFamily: AppTheme.fontFamily,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromRGBO(210, 210, 210, 1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.danger, width: 1.5),
      ),
    );
  }
}
