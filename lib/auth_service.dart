import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final bool success;
  final String message;

  const AuthResult({
    required this.success,
    required this.message,
  });
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _continueUrl = 'https://capstone-majadigi.web.app/login';
  static const String _androidPackageName = 'com.example.capstonemajadigi';

  User? get currentUser => _auth.currentUser;

  ActionCodeSettings _buildActionCodeSettings() {
    return ActionCodeSettings(
      url: _continueUrl,
      handleCodeInApp: false,
      androidPackageName: _androidPackageName,
      androidInstallApp: true,
      androidMinimumVersion: '1',
    );
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return const AuthResult(
          success: false,
          message: 'Gagal membuat akun.',
        );
      }

      await user.updateDisplayName(name.trim());

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'status': 'pending',
        'isEmailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _auth.setLanguageCode('id');
      await user.sendEmailVerification(_buildActionCodeSettings());

      return const AuthResult(
        success: true,
        message: 'Email verifikasi berhasil dikirim.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _mapRegisterError(e),
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Terjadi kesalahan saat registrasi.',
      );
    }
  }

  Future<AuthResult> resendVerificationEmail() async {
    try {
      await currentUser?.reload();
      final user = _auth.currentUser;

      if (user == null) {
        return const AuthResult(
          success: false,
          message: 'Sesi pengguna tidak ditemukan. Silakan daftar lagi.',
        );
      }

      if (user.emailVerified) {
        await _markUserActive(user);
        return const AuthResult(
          success: true,
          message: 'Email sudah diverifikasi.',
        );
      }

      await _auth.setLanguageCode('id');
      await user.sendEmailVerification(_buildActionCodeSettings());

      return const AuthResult(
        success: true,
        message: 'Email verifikasi berhasil dikirim ulang.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _mapGenericAuthError(e),
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Gagal mengirim ulang email verifikasi.',
      );
    }
  }

  Future<AuthResult> refreshVerificationStatus() async {
    try {
      await currentUser?.reload();
      final user = _auth.currentUser;

      if (user == null) {
        return const AuthResult(
          success: false,
          message: 'Sesi pengguna tidak ditemukan.',
        );
      }

      if (!user.emailVerified) {
        return const AuthResult(
          success: false,
          message: 'Email belum diverifikasi. Cek inbox atau folder spam.',
        );
      }

      await _markUserActive(user);

      return const AuthResult(
        success: true,
        message: 'Email berhasil diverifikasi.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _mapGenericAuthError(e),
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Gagal memeriksa status verifikasi email.',
      );
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return const AuthResult(
          success: false,
          message: 'Login gagal.',
        );
      }

      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return const AuthResult(
          success: false,
          message: 'Pengguna tidak ditemukan setelah login.',
        );
      }

      if (!refreshedUser.emailVerified) {
        await _auth.signOut();
        return const AuthResult(
          success: false,
          message: 'Email belum diverifikasi. Silakan verifikasi email terlebih dahulu.',
        );
      }

      await _markUserActive(refreshedUser);

      return const AuthResult(
        success: true,
        message: 'Login berhasil.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _mapLoginError(e),
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Terjadi kesalahan saat login.',
      );
    }
  }

  Future<AuthResult> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.setLanguageCode('id');

      await _auth.sendPasswordResetEmail(
        email: email.trim(),
        actionCodeSettings: _buildActionCodeSettings(),
      );

      return const AuthResult(
        success: true,
        message: 'Email reset kata sandi berhasil dikirim.',
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return const AuthResult(
            success: false,
            message: 'Format email tidak valid.',
          );
        case 'user-not-found':
          return const AuthResult(
            success: false,
            message: 'Akun dengan email tersebut tidak ditemukan.',
          );
        case 'network-request-failed':
          return const AuthResult(
            success: false,
            message: 'Koneksi internet bermasalah.',
          );
        case 'unauthorized-continue-uri':
          return const AuthResult(
            success: false,
            message: 'Domain reset password belum diizinkan di Firebase.',
          );
        default:
          return AuthResult(
            success: false,
            message: 'Gagal mengirim email reset. (${e.code})',
          );
      }
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Terjadi kesalahan saat mengirim email reset.',
      );
    }
  }

  Future<AuthResult> saveUserLocation({
    required String? city,
    required String? regency,
    required String? province,
    required String source,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return const AuthResult(
          success: false,
          message: 'Sesi pengguna tidak ditemukan.',
        );
      }

      await _firestore.collection('users').doc(user.uid).set({
        'location': {
          'city': city?.trim(),
          'regency': regency?.trim(),
          'province': province?.trim(),
          'source': source,
          'latitude': latitude,
          'longitude': longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return const AuthResult(
        success: true,
        message: 'Lokasi berhasil disimpan.',
      );
    } on FirebaseException catch (e) {
      return AuthResult(
        success: false,
        message: 'Gagal menyimpan lokasi. (${e.code})',
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Terjadi kesalahan saat menyimpan lokasi.',
      );
    }
  }

  Future<AuthResult> saveUserServicePreferences({
    required List<String> serviceIds,
    required List<String> serviceNames,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return const AuthResult(
          success: false,
          message: 'Sesi pengguna tidak ditemukan.',
        );
      }

      await _firestore.collection('users').doc(user.uid).set({
        'servicePreferences': {
          'selectedIds': serviceIds,
          'selectedNames': serviceNames,
          'source': 'onboarding_step_2',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return const AuthResult(
        success: true,
        message: 'Preferensi layanan berhasil disimpan.',
      );
    } on FirebaseException catch (e) {
      return AuthResult(
        success: false,
        message: 'Gagal menyimpan preferensi layanan. (${e.code})',
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Terjadi kesalahan saat menyimpan preferensi layanan.',
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _markUserActive(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email?.toLowerCase(),
      'name': user.displayName,
      'status': 'active',
      'isEmailVerified': true,
      'verifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _mapRegisterError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      case 'unauthorized-continue-uri':
        return 'Domain verifikasi email belum diizinkan di Firebase.';
      default:
        return 'Registrasi gagal. (${e.code})';
    }
  }

  String _mapLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'invalid-credential':
        return 'Email atau kata sandi salah.';
      case 'user-not-found':
        return 'Akun tidak ditemukan.';
      case 'wrong-password':
        return 'Kata sandi salah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      default:
        return 'Login gagal. (${e.code})';
    }
  }

  String _mapGenericAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'too-many-requests':
        return 'Terlalu banyak permintaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      case 'unauthorized-continue-uri':
        return 'Domain aksi email belum diizinkan di Firebase.';
      default:
        return 'Terjadi kesalahan. (${e.code})';
    }
  }
}