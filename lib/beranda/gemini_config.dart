/// Konfigurasi API Gemini.
///
/// API key TIDAK boleh di-hardcode di source code — selalu lewat
/// `--dart-define=GEMINI_API_KEY=...` saat build/run.
///
/// Contoh menjalankan app:
/// ```
/// flutter run --dart-define=GEMINI_API_KEY=AIzaXXXX
/// flutter build apk --release --dart-define=GEMINI_API_KEY=AIzaXXXX
/// ```
///
/// Untuk pengembangan di IDE: tambahkan argument run/configuration di
/// Android Studio (Run → Edit Configurations → Additional run args).
const String kGeminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);

bool get hasGeminiApiKey => kGeminiApiKey.isNotEmpty;
