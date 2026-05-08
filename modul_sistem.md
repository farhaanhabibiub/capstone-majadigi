# Modul Sistem — Majadigi

Dokumentasi lengkap modul aplikasi **Majadigi**, platform layanan publik digital Provinsi Jawa Timur berbasis Flutter + Firebase BaaS. Dokumen ini memetakan setiap modul ke fungsi, input, dan output yang dihasilkan, dikelompokkan dalam 8 kategori untuk memudahkan navigasi.

> **Tanggal**: 2026-05-08
> **Repo**: `capstonemajadigi`
> **Dokumen pelengkap**: `arsitektur_sistem.svg`, `alur_sistem.svg`

## Daftar Isi

1. [Auth & Onboarding](#1-auth--onboarding)
2. [Beranda & Hub](#2-beranda--hub)
3. [Fitur Core (5 Layanan Unggulan)](#3-fitur-core-5-layanan-unggulan)
4. [Fitur Addable (Deferred-Loaded)](#4-fitur-addable-deferred-loaded)
5. [Maja AI & Engagement](#5-maja-ai--engagement)
6. [Profil & Akun](#6-profil--akun)
7. [Admin & Moderation](#7-admin--moderation)
8. [Common & Infrastructure](#8-common--infrastructure)
9. [Ringkasan](#ringkasan)

---

## 1. Auth & Onboarding

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Splash Screen** (`lib/splash_screen.dart`) | Gateway aplikasi; tampilkan logo lalu route ke layar yang sesuai berdasarkan status auth & flag onboarding. | flag `onboarding_seen` (SharedPreferences); `FirebaseAuth.currentUser` | Navigasi ke `/onboarding`, `/loginPage`, atau `/berandaPage` |
| **Onboarding** (`lib/onboarding.dart`) | Tutorial 3 slide untuk pengguna baru, jelaskan personalisasi & layanan unggulan. | Swipe slide; tap "Mulai" | Set `onboarding_seen=true`; navigasi ke `/loginPage` |
| **Login** (`lib/login_page.dart`) | Form login email/password; opsional unlock biometrik. | Email & Password (TextField); biometric prompt | `FirebaseAuth.signInWithEmailAndPassword`; simpan FCM token ke `users/{uid}.fcmToken`; navigasi ke `/berandaPage` |
| **Register** (`lib/register_page.dart`) | Form registrasi akun baru dengan validasi & strength meter password. | Nama, Email, Telepon, Password, Confirm Password (TextField) | `createUserWithEmailAndPassword`; doc `users/{uid}` (status=`pending`, `isEmailVerified=false`); kirim email verifikasi → `/verifyEmailPage` |
| **Verify Email** (`lib/verify_email_page.dart`) | Tunggu user klik link verifikasi; tombol Resend dengan cooldown 60 dtk. | Email (route arg); tap Resend / Cek status | `refreshVerificationStatus`; jika sukses → `_markUserActive` (`status='active'`, `isEmailVerified=true`); navigasi ke `/personalizationLocationPage` |
| **Forget Password** (`lib/forget_password.dart`) | Form input email untuk kirim reset link. | Email (TextField) | `sendPasswordResetEmail`; navigasi ke `/emailSentPage` |
| **Email Sent** (`lib/email_sent_page.dart`) | Konfirmasi reset link sudah dikirim. | Email (route arg) | UI konfirmasi; tombol "Kembali ke Login" |
| **Personalization Location** (`lib/personalization_location.dart`) | Auto-detect lokasi via GPS, fallback ke manual. | Geolocator + reverse geocoding (lat, long → city, regency) | `AuthService.saveUserLocation()` → `users/{uid}.location`; navigasi ke `/personalizationServicesPage` |
| **Location Manual** (`lib/location_manual_page.dart`) | Pilih kota/kabupaten dari CSV `assets/data/jatim_kecamatan.csv`. | Dropdown city + regency | `users/{uid}.location` (source=`manual`) |
| **Personalization Services** (`lib/personalization_services_page.dart`) | Multi-select kategori minat (mobilitas, ekonomi, pekerjaan, kesehatan, sosial, pemerintahan, keamanan). | Checkbox kategori | `AuthService.saveUserServicePreferences()` → `users/{uid}.servicePreferences.selectedIds`; → `/personalizationSuccessPage` |
| **Personalization Success** (`lib/personalization_success_page.dart`) | Konfirmasi onboarding selesai. | — | Navigasi ke `/berandaPage` |
| **Personalization Rule Base** (`lib/personalization_rule_base.dart`) | Engine skor multi-kategori (rank 1=5pt … 5=1pt) untuk pilih 5 fitur unggulan; replace `rsud` generik → RSUD terdekat via `HospitalConfig.forLocation`. | `selectedCategoryIds: List<String>`, `city: String`, `regency: String` | `List<String>` 5 featureId terurut |

---

## 2. Beranda & Hub

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Beranda Page** (`lib/beranda/beranda_page.dart`) | Hub utama: 5 layanan unggulan (rule-base), shortcut favorit, search bar, banner, berita, Maja AI floating. Bottom nav: Beranda / Favorit / Profil. | Cache `ProfileCache` → fetch `users/{uid}` dari Firestore; bottom nav tap | Render layanan + addedServices + tombol "Tambah Layanan"; navigasi ke fitur via `Navigator.pushNamed` |
| **Favorit Tab** (`lib/beranda/favorit_tab.dart`) | Daftar layanan yang di-bookmark user (key `fav_<id>` di SharedPreferences). | Keys SharedPreferences | List card shortcut → tap navigasi ke fitur |
| **Global Search** (`lib/beranda/global_search_page.dart`) | Pencarian lintas fitur (layanan, RSUD, hoaks, open data, profil settings) + history pencarian. | Query string (TextField) | List hasil per kategori; simpan ke `global_search_recent` |
| **Search Index** (`lib/beranda/search_index.dart`) | Static catalog `SearchableItem` (id, title, subtitle, keywords, route, args). | — | Sumber data untuk Global Search |
| **Service Registry** (`lib/beranda/service_registry.dart`) | Katalog metadata fitur addable & core (`AddableService`, `FeatureMeta`). | — | `ServiceRegistry.all`; `findById(id)`; `metaFor(id)` |
| **Tambah Layanan** (`lib/beranda/tambah_layanan_page.dart`) | Pilih layanan addable untuk ditambahkan ke beranda. | Multi-select dari `ServiceRegistry.all` | `AuthService.saveAddedServices()` → `users/{uid}.addedServices`; prefetch aset via `FeatureAssetService` |
| **Deferred Feature Page** (`lib/beranda/deferred_feature_page.dart`) | Wrapper generic untuk lazy-load fitur addable via `import deferred as`. | `loader: Future<void> Function()`, `builder: WidgetBuilder`, `featureLabel: String` | Loading UI → render fitur setelah `loadLibrary()` selesai; UI retry jika error |
| **Notifikasi Page** (`lib/beranda/notifikasi_page.dart`) | Daftar notifikasi (status tiket, info layanan) dari Firestore `notifications`. | Stream `notifications` desc by `createdAt` | List card; `markAllSeen` saat halaman dibuka |

---

## 3. Fitur Core (5 Layanan Unggulan)

### 3.1 Bapenda — Pajak Kendaraan

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Bapenda Page** (`lib/bapenda/bapenda_page.dart`) | Landing 2 tab: Layanan (Info Pajak, Estimasi NJKB) & Informasi (operasional, ketentuan). | Tab index; favorite toggle (`fav_bapenda`) | Render tab; navigasi ke `/infoPajakPage` atau `/estimasiNjkbPage` |
| **Info Pajak** (`lib/bapenda/info_pajak_page.dart`) | Cek pajak kendaraan via plat nomor + 5 digit terakhir nomor rangka. | Plat nomor (TextField, regex Jatim); 5 digit no rangka; CSV `assets/data/kendaraan_jatim.csv` | `KendaraanData` → `/hasilPajakPage` |
| **Hasil Pajak** (`lib/bapenda/hasil_pajak_page.dart`) | Tampilkan detail PKB, BBN, opsen, SWDKLLJ, parkir, biaya STNK/TNKB. | `KendaraanData` (route arg) | Card hasil terformat; tombol link ke web Bapenda |
| **Estimasi NJKB** (`lib/bapenda/estimasi_njkb_page.dart`) | Estimasi Nilai Jual Kendaraan via dropdown jenis/merk/model/tipe/tahun. | Dropdown selections; CSV `assets/data/njkb_database.csv` | `HasilNjkbData` → `/hasilNjkbPage` |
| **Hasil NJKB** (`lib/bapenda/hasil_njkb_page.dart`) | Tampilkan nilai NJKB + estimasi pajak tahunan. | `HasilNjkbData` (route arg) | Detail formatted; link daftar ulang Bapenda |

### 3.2 RSUD

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **RSUD Page** (`lib/rsud/rsud_page.dart`) | Landing rumah sakit (2 tab: Layanan & Informasi); 4 RS: Daha Husada, Saiful Anwar, Karsa Husada, Prov. Jatim. | `HospitalConfig` (route arg); favorite toggle (`fav_rsud_<id>`) | Navigasi ke kamar/jadwal/antrean dengan arg `HospitalConfig`; info kontak & sosial |
| **Hospital Config** (`lib/rsud/hospital_config.dart`) | Static config 4 RS (id, name, city, path CSV); helper `forLocation(city, regency)`. | `city`, `regency` | `HospitalConfig` terdekat |
| **Ketersediaan Kamar** (`lib/rsud/ketersediaan_kamar_page.dart`) | Tabel kamar (ruang, kelas, kapasitas, terisi, sisa). | `HospitalConfig`; CSV `kamar_<rs>.csv` | Tabel data; highlight merah jika sisa rendah; timestamp update |
| **Jadwal Operasi** (`lib/rsud/jadwal_operasi_page.dart`) | Daftar jadwal operasi (tanggal, jam, dokter, status). | `HospitalConfig`; CSV `jadwal_<rs>.csv` | List sorted by tanggal; filter status |
| **Info Antrean** (`lib/rsud/info_antrean_page.dart`) | Antrean poli (poli, dokter, jam, nomor antrean berjalan, total, sisa, ETA). | `HospitalConfig`; CSV `antrean_<rs>.csv` | List per poli; dropdown filter poli |

### 3.3 Transjatim

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Transjatim Page** (`lib/transjatim/transjatim_page.dart`) | Hub fitur: Beli Tiket, Rute, Peta Halte, Riwayat. | Tab index; `transjatim_dummy_data.dart` | Render tab; widget `HalteMapWidget`, `RouteCard` |
| **Buy Ticket** (`lib/transjatim/pages/buy_ticket_page.dart`) | Form beli tiket: kota asal, tujuan, tanggal, jumlah penumpang. | Dropdowns + TextField tanggal/pax | Navigasi ke `/payment` dengan model order |
| **Payment** (`lib/transjatim/pages/payment_page.dart`) | Simulasi pembayaran: metode bayar, konfirmasi total. | Order data; metode pembayaran | Navigasi ke `TicketResultPage`; simpan riwayat |
| **Ticket Result** (`lib/transjatim/pages/ticket_result_page.dart`) | Tampilkan tiket: nomor, kursi, kode QR, waktu keberangkatan. | TicketInfo | UI tiket dengan `qr_flutter`; tombol share |
| **Ticket History Service** (`lib/transjatim/ticket_history_service.dart`) | Persist & query riwayat tiket (SharedPreferences). | TicketInfo (add); query | List riwayat untuk tab Riwayat |

### 3.4 Siskaperbapo

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Siskaperbapo Page** (`lib/siskaperbapo/siskaperbapo_page.dart`) | Pantau harga sembako per kabupaten + tren bulanan. | Dropdown kabupaten; search item | List kartu harga + grafik tren via `PriceGraphPainter` |
| **Sembako Card / Info Card** (`lib/siskaperbapo/widgets/`) | Komponen UI: kartu harga, badge indikator naik/turun. | `SembakoItem`, harga sebelumnya | Render card |
| **Price Graph Painter** (`lib/siskaperbapo/widgets/price_graph_painter.dart`) | Custom painter line chart harga vs waktu. | List harga + tanggal | Canvas line chart |

### 3.5 Nomor Darurat

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Landing** (`lib/nomordarurat_landing_page.dart`) | Hub nomor darurat: Cari Nomor & Informasi. | Tab index; favorite toggle | Render tab |
| **Cari Nomor** (`lib/nomordarurat_carinomor.dart`) | Cari nomor per kategori (Polisi, Damkar, Ambulans) & wilayah. | Kategori dropdown; kota/kabupaten | List nomor; tombol direct dial via `url_launcher` (`tel:`) |
| **Informasi** (`lib/nomordarurat_informasi.dart`) | FAQ & cara melapor darurat. | — | Konten statis |

---

## 4. Fitur Addable (Deferred-Loaded)

### 4.1 Sapa Bansos

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Sapa Bansos Page** (`lib/sapabansos/sapa_bansos_page.dart`) | Cek status penerima bansos; 3 tab: Penerima, Program, Tentang. | Favorite toggle; user UID | Render tab terpilih |
| **Penerima Tab** (`lib/sapabansos/widgets/penerima_tab.dart`) | Form cek penerima: NIK / no pendaftaran. | NIK (TextField); CSV `penerima_bansos.csv` | Status penerima (nama, program, periode) atau "Belum terdata" |
| **Program Tab** (`lib/sapabansos/widgets/program_tab.dart`) | Daftar program bansos dengan detail & syarat. | `sapabansos_dummy_data.dart` | List `ProgramCard`; navigasi ke `ProgramDetailPage` |
| **Sapa Bansos Data Service** (`lib/sapabansos/data/sapabansos_data_service.dart`) | Fetch & cache data program/penerima. | — | `List<Program>`, status penerima |

### 4.2 Etibi (Skrining TBC)

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Etibi Page** (`lib/etibi/etibi_page.dart`) | Hub skrining TBC; 3 tab: Skrining, Riwayat, Tentang. | Tab index; favorite toggle | Render tab |
| **Skrining Tab** (`lib/etibi/widgets/skrining_tab.dart`) | Kuesioner gejala TBC; scoring → risk level. | Radio answer 10–15 pertanyaan | Skor + rekomendasi (rendah/sedang/tinggi); save ke Firestore `users/{uid}/skrining_riwayat`; jadwalkan reminder 6 bulan |
| **Riwayat Tab** (`lib/etibi/widgets/riwayat_tab.dart`) | Daftar hasil skrining sebelumnya. | Stream `users/{uid}/skrining_riwayat` desc | List `RiwayatSkrining` |
| **Tentang Tab** (`lib/etibi/widgets/tentang_tab.dart`) | Info TBC (definisi, gejala, pencegahan). | — | Rich text statis |

### 4.3 Klinik Hoaks

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Klinik Hoaks Landing** (`lib/klinikhoaks_landing_page.dart`) | Pengantar fitur + tombol lapor. | Favorite toggle | Navigasi ke `/klinikHoaksPermohonanPage` |
| **Klinik Hoaks Permohonan** (`lib/klinikhoaks_permohonan.dart`) | Form lapor hoaks + daftar laporan user; real-time status. | Topik, isi, link bukti, file (`file_picker`) | Upload file → Firebase Storage; doc `laporan_hoaks/{docId}` (uid, topik, isi, fileUrl, status=`Diproses`, `createdAtMs`) |
| **Klinik Hoaks Lihat Detail** (`lib/klinikhoaks_lihatdetail.dart`) | Detail laporan + status verifikasi. | `LaporanHoaks` (route arg) | Tampil detail; admin: form ubah status |
| **Klinik Hoaks Model** (`lib/klinikhoaks_model.dart`) | Model data laporan. | Map dari Firestore | `LaporanHoaks` instance |

### 4.4 Open Data

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Open Data Landing** (`lib/open_data_landing_page.dart`) | Hub open data Jatim. | Favorite toggle | Navigasi ke list/detail |
| **Open Data List** (`lib/open_data_list_page.dart`) | Katalog dataset (UMKM, MBG, Ayo Pasok). | Search query; filter kategori | List card → `/openDataDetailPage` / khusus |
| **Open Data Detail** (`lib/open_data_detail_page.dart`) | Detail metadata dataset (judul, deskripsi, source). | Dataset metadata (route arg) | UI detail; link download eksternal |
| **Data Sebaran UMKM** (`lib/open_data_datasebaran.dart`) | Visualisasi sebaran UMKM per kecamatan. | — | Tabel/peta sebaran |
| **Dapur MBG** (`lib/open_data_dapurmbg.dart`) | Artikel panduan Dapur Makan Bergizi. | — | Rich text + gambar |
| **Ayo Pasok** (`lib/open_data_ayopasok.dart`) | Infografis cara jadi supplier MBG. | — | Infografis + detail aplikasi |
| **Open Data Informasi** (`lib/open_data_informasi.dart`) | FAQ & lisensi data. | — | Konten statis |

---

## 5. Maja AI & Engagement

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Gemini Service** (`lib/beranda/gemini_service.dart`) | Wrapper `google_generative_ai`; model `gemini-3-flash-preview` dengan system prompt sebagai asisten 9 layanan Jatim; temp 0.7, max 1024 token. | `--dart-define=GEMINI_API_KEY=...`; optional history `List<Content>` | `ChatSession` untuk streaming |
| **Gemini Config** (`lib/beranda/gemini_config.dart`) | Compile-time API key + flag `hasGeminiApiKey`. | dart-define | Const `kGeminiApiKey`; bool flag |
| **Maja AI Chat** (`lib/beranda/maja_ai_chat_page.dart`) | UI chat: streaming chunk, suggestion dinamis, rate limit 8 msg/60 dtk (sliding window via `Queue<DateTime>`), tombol Stop. | Text user; suggestion chip tap | `chat.sendMessageStream`; render bubble; simpan ke Firestore via `MajaAiHistoryService.add` |
| **Maja AI History Service** (`lib/beranda/maja_ai_history_service.dart`) | Persist & load riwayat chat per user. | `text`, `isUser`; uid | Doc subcollection user → `loadAll()`, `add()`, `clearAll()` |
| **Feature Usage Service** (`lib/beranda/feature_usage_service.dart`) | Catat pembukaan fitur (all-time, monthly, recent 20); sumber data untuk Maja suggestion & Profil stats. | `featureId: String` | Counts di SharedPreferences (`feature_usage.<id>`, `feature_usage_monthly.YYYY-MM.<id>`); list `RecentOpen`, `MonthlyStat` |
| **Feature Asset Service** (`lib/beranda/feature_asset_service.dart`) | Prefetch aset fitur addable; download manifest dari Storage; fallback ke bundled. | `featureId`; `onProgress` callback | `FeaturePrefetchResult`; cache lokal aset |
| **Streak Service** (`lib/common/streak_service.dart`) | Track daily login streak (current, longest, lastVisit); idempotent per hari, decay jika gap >1 hari. | — | `StreakSnapshot{current, longest, lastVisit}` |
| **Achievement Service** (`lib/common/achievement_service.dart`) | Evaluasi lencana dari kombinasi streak + unique features + total opens. | Snapshot data | `List<Achievement>` dengan progress (%) |

---

## 6. Profil & Akun

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Profil Tab** (`lib/profil/profil_tab.dart`) | Dashboard profil: avatar, streak banner, stat bulan ini, aktivitas terakhir, menu akun, panel admin (jika `isAdmin`), info, hapus akun, keluar. | `FirebaseAuth.currentUser`; `FeatureUsageService.recentOpens(5)` & `topThisMonth(3)`; `StreakService.read()`; `AuthService.isAdmin()` | Render section; navigasi ke sub-page |
| **Ubah Profil** (`lib/profil/ubah_profil_page.dart`) | Edit nama, telepon, foto profil (image_picker + crop). | Nama, telepon (TextField); foto (`image_picker` → `image_cropper`) | Upload ke Firebase Storage `users/{uid}/profile.jpg`; update `displayName` & `users/{uid}` Firestore |
| **Keamanan Akun** (`lib/profil/keamanan_akun_page.dart`) | Ganti password (strength meter); enable/disable biometric. | Old/New/Confirm password; toggle biometric | `updatePassword`; `BiometricService.enable(email)` / `.disable()` |
| **Aksesibilitas** (`lib/profil/aksesibilitas_page.dart`) | Atur tema (light/dark) & skala font (small/normal/large). | Toggle tema; selector font | Update `ThemeController.notifier`, `FontScaleController.notifier`; persist SharedPreferences |
| **Lencana** (`lib/profil/lencana_page.dart`) | Daftar lencana yang sudah/belum unlock dengan progress. | `AchievementService.evaluate()` | Visual badge locked/unlocked |

---

## 7. Admin & Moderation

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Admin Page** (`lib/admin/admin_page.dart`) | Panel moderasi laporan hoaks; filter status (Semua/Diproses/Diverifikasi/Selesai); detail bottom sheet untuk ubah status. | Stream `laporan_hoaks` order by `createdAtMs` desc; filter dropdown | Update `laporan_hoaks/{docId}.status`; `AuditLogService.record()` |
| **Admin Session Guard** (`lib/admin/admin_session_guard.dart`) | Middleware cek apakah user terdaftar di collection `admins/{uid}`; blokir jika bukan admin. | `FirebaseAuth.currentUser.uid` | Render child jika admin; kick-out jika tidak |
| **Admin Notifikasi** (`lib/admin/admin_notifikasi_page.dart`) | Compose & broadcast notifikasi ke semua user via FCM + Firestore `notifications`. | Title, body; segmen | Doc baru di `notifications`; FCM fan-out token |
| **Audit Log Page** (`lib/admin/audit_log_page.dart`) | Daftar event admin (login, ubah status, dll) dengan filter event type & rentang tanggal. | Stream `audit_logs` | List `AuditLogEntry` |
| **Audit Log Service** (`lib/admin/audit_log_service.dart`) | Catat aksi admin ke Firestore `audit_logs`. | `action`, `targetType`, `targetId`, `details: Map` | Doc baru `audit_logs/{id}` (uid, action, timestamp, details) |

---

## 8. Common & Infrastructure

### 8.1 Layanan Domain

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Auth Service** (`lib/auth_service.dart`) | Centralized Firebase Auth + Firestore (register, login, verify, resetPassword, saveLocation/Preferences/AddedServices, signOut, isAdmin). | Email, password, profile fields | `AuthResult{success, message}`; doc `users/{uid}`; clear state saat logout |
| **Notification Service** (`lib/notification_service.dart`) | Init `flutter_local_notifications` + timezone; handler FCM background; show status update notif. | Init; tiketId, status | Local notif scheduling/dispatch |
| **Profile Cache** (`lib/common/profile_cache.dart`) | Offline cache profile (location, addedServices, servicePreferences) di SharedPreferences. | `city/regency`; list ids/preferences | Get/save methods; `clear()` saat logout |
| **Favorite Service** (`lib/common/favorite_service.dart`) | Wrapper SharedPreferences untuk bookmark layanan (key `fav_<slug>`). | Key string, bool | Get/set bool |
| **Favorite Mixin** (`lib/common/favorite_mixin.dart`) | Mixin untuk page yang butuh bookmark; abstract `favoriteKey`, `favoriteLabel`; method `toggleFavorite()`. | — | `isFavorite` getter; toggle handler |
| **Biometric Service** (`lib/common/biometric_service.dart`) | Wrapper `local_auth` (fingerprint/face); flag enabled + enrolled email. | enroll email; reason string | `isAvailable()`, `isEnabled()`, `authenticate(reason)` → bool |
| **Share Service** (`lib/common/share_service.dart`) | Wrapper `share_plus` untuk system share sheet. | text, optional URL | Pop system share dialog |

### 8.2 Tema & UI

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **App Theme** (`lib/theme/app_theme.dart`) | Palet & tipografi terpusat; helper context-aware (`backgroundOf`, `surfaceOf`, `textPrimaryOf`) untuk light/dark. | `BuildContext` | Color & TextStyle constants; `ThemeData` light/dark |
| **Theme Controller** (`lib/theme/theme_controller.dart`) | `ValueNotifier<ThemeMode>`; persist di SharedPreferences. | toggle light/dark | Notifier broadcast → MaterialApp rebuild |
| **Font Scale Controller** (`lib/theme/font_scale_controller.dart`) | `ValueNotifier<FontScaleOption>` (small/normal/large); persist di SharedPreferences. | font selection | `MediaQuery.textScaler` override |
| **Empty State** (`lib/widgets/empty_state.dart`) | Placeholder "tidak ada data" dengan icon/title/subtitle/CTA. | icon, title, subtitle, action | Widget reusable |
| **Error Retry** (`lib/widgets/error_retry.dart`) | Boundary error dengan tombol retry. | error message; onRetry callback | UI error + tombol |
| **Skeleton Loader** (`lib/widgets/skeleton_loader.dart`) | Shimmer placeholder saat fetch. | itemCount; layout type | Animated skeleton |
| **Password Strength Meter** (`lib/widgets/password_strength_meter.dart`) | Visual indikator kekuatan password. | password string | Bar + label (lemah/sedang/kuat) |

### 8.3 Routing & Bootstrap

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **App Route** (`lib/app_route.dart`) | Daftar semua route; eager-load core, lazy-load addable via `import deferred as`; `generateRoute()` factory. | `RouteSettings{name, arguments}` | `FadePageRoute` / `SlidePageRoute` dengan widget builder |
| **App Transitions** (`lib/app_transitions.dart`) | Custom transitions: `FadePageRoute`, `SlidePageRoute`; tag `HeroTags` (profileAvatar, serviceCard). | route name | PageRouteBuilder |
| **Firebase Options** (`lib/firebase_options.dart`) | Auto-generated config FlutterFire CLI per platform. | — | `DefaultFirebaseOptions.currentPlatform` |
| **Main** (`lib/main.dart`) | Entry point: init Firebase, NotificationService, ThemeController, FontScaleController, FCM listeners, save FCM token; runApp. | — | `MaterialApp` ter-bootstrap dengan ValueListenableBuilder × 2 |

### 8.4 Backend Node (Sekunder/Legacy)

| Modul | Fungsi | Input | Output |
|---|---|---|---|
| **Server** (`backend/src/server.js`) | Express bootstrap; CORS allowlist; mount `/api/auth`; health check `/health`. | `process.env.PORT`, `ALLOWED_ORIGINS` | HTTP listener |
| **Auth Routes** (`backend/src/routes/`) | REST endpoint untuk register/login/reset (legacy). | HTTP request body | JSON response `{success, message, data}` |
| **Auth Controllers / Services / Models** (`backend/src/{controllers,services,models}/`) | Business logic auth: hash bcryptjs, kirim email nodemailer, query Mongoose. | Request DTO | User document MongoDB |
| **DB Config** (`backend/src/config/`) | `connectDB` ke MongoDB via Mongoose. | `MONGO_URI` env | Connection pool |

---

## Ringkasan

| # | Kategori | Jumlah Modul | Catatan |
|---|---|---|---|
| 1 | Auth & Onboarding | 12 | Termasuk rule-base personalisasi |
| 2 | Beranda & Hub | 8 | Hub utama + global search |
| 3 | Fitur Core | 18 | Bapenda 5, RSUD 5, Transjatim 5, Siskaperbapo 3, Nomor Darurat 3 |
| 4 | Fitur Addable | 18 | Sapa Bansos 4, Etibi 4, Klinik Hoaks 4, Open Data 7 — semua deferred-loaded |
| 5 | Maja AI & Engagement | 8 | Gemini chat + analytics + gamifikasi |
| 6 | Profil & Akun | 5 | Termasuk aksesibilitas & lencana |
| 7 | Admin & Moderation | 5 | Dengan audit log |
| 8 | Common & Infrastructure | 18 | Domain services + UI theme + routing + backend Node |
| **Total** | — | **~92 modul utama** | — |

### Catatan Implementasi
- **Storage**: Firestore untuk dokumen dinamis; Firebase Storage untuk file; SharedPreferences untuk cache lokal & analytics ringan; CSV assets untuk data statis
- **Auth**: Firebase Auth dengan email verification mandatory + biometric opsional
- **AI**: Gemini API dengan rate limit client-side & streaming response
- **Personalisasi**: Rule-base scoring di klien; lokasi-aware (RSUD terdekat)
- **Aksesibilitas**: Light/dark theme + 3 skala font + Semantics widget
- **Code-splitting**: 4 fitur addable di-lazy-load via `deferred as` untuk hemat memori awal

---

*Dokumen ini dibuat untuk dokumentasi capstone Majadigi. Dilengkapi dengan diagram arsitektur (`arsitektur_sistem.svg`) dan diagram alur (`alur_sistem.svg`).*
