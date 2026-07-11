# Pembagian Tugas — Capstone Majadigi

Pembagian peran dan tanggung jawab tim pengembang aplikasi **Majadigi**, platform layanan publik digital Provinsi Jawa Timur.

> **Tanggal**: 2026-05-08
> **Repo**: [farhaanhabibiub/capstone-majadigi](https://github.com/farhaanhabibiub/capstone-majadigi)

## Tim

| Nama | Role | Fokus Utama |
|---|---|---|
| **Farhan** | Backend Developer | Service layer, integrasi Firebase, business logic, data pipeline |
| **Ghairan** | Front-End Developer | UI/UX, layout, navigation, state management, design system |
| **Faris** | Testing Fitur | Skenario uji, bug discovery, regression testing, dokumentasi QA |

---

## 1. Farhan — Backend Developer

### Tanggung Jawab Utama
Mengelola sisi data, integrasi server (Firebase + Node.js + Gemini API), business logic, validasi, dan mekanisme keamanan. Memastikan setiap fitur punya backbone data yang reliable, secure, dan scalable.

### Scope Pekerjaan

#### A. Integrasi Firebase (BaaS)
- **Authentication** — `lib/auth_service.dart`: register, login, email verification, password reset, save profile/location/preferences
- **Cloud Firestore** — desain skema dokumen & collection: `users/`, `notifications/`, `laporan_hoaks/`, `admins/`, `audit_logs/`, `transjatim_tickets/`, subcollection `users/{uid}/majaAiChats/`
- **Firestore Security Rules** — owner-only access, admin guard, fallback authenticated read/write untuk koleksi lain
- **Firebase Storage** — `laporan_hoaks/{tiketId}/{file}` (lampiran hoaks), `users/{uid}/profile.jpg` (foto profil); plus Storage Rules untuk size limit & content-type
- **Firebase Cloud Messaging (FCM)** — token registration, background handler, push notification status update tiket

#### B. Domain & Service Layer
- `PersonalizationRuleBase` — engine skor multi-kategori (rank 1=5pt … 5=1pt) untuk pilih 5 layanan unggulan + RSUD-by-location
- `ServiceRegistry` — katalog metadata fitur addable & core
- `FeatureUsageService` — tracking pembukaan fitur (all-time + monthly + recent), sumber data untuk Maja AI suggestion & Profil stats
- `ProfileCache` — offline-first cache (SharedPreferences) untuk location & preferences
- `StreakService` & `AchievementService` — gamifikasi (streak harian, lencana)
- `BiometricService` — wrapper `local_auth` (fingerprint/face)
- `ShareService` — wrapper `share_plus`
- `FavoriteService` & `FavoriteMixin` — bookmark layanan

#### C. AI & Engagement
- `GeminiService` — integrasi `google_generative_ai` (model `gemini-3-flash-preview`) dengan system prompt 9 layanan Jatim
- `MajaAiHistoryService` — persist chat history ke Firestore + load history sebagai context
- **Rate limiter sliding window** di Maja AI chat (8 pesan / 60 detik via `Queue<DateTime>`)
- API key security via `--dart-define=GEMINI_API_KEY=...`

#### D. Transjatim Ticketing System
- `TransjatimTicketService` — write tiket ke Firestore saat bayar
- **One-shot scan logic** dengan `runTransaction` — atomic `active → used` (tahan race antar admin)
- `TicketScanOutcome` (success / alreadyUsed / notFound / error)
- Backward-compat: rebuild `TicketOrder` dari history map dengan fallback `indexWhere` saat field `fromIndex/toIndex` belum ada

#### E. Admin & Audit
- `AuditLogService` — record semua aksi admin (`mark_ticket_used`, `update_laporan_status`, dll.) ke Firestore `audit_logs/`
- `AdminSessionGuard` — middleware cek `admins/{uid}` → blokir akses panel jika bukan admin

#### F. Validasi & File Handling
- Validation logic: regex email/phone, password strength (min 8 char + huruf + angka), link format (http/https), confirm-password match
- File upload Firebase Storage: pakai `putData(bytes, SettableMetadata)` untuk content URI Android modern, MIME type proper, validasi 10 MB
- Parse CSV cross-platform (BOM stripping, multi-delimiter)

#### G. Data Pipeline (CSV Asset Curation)
- Curate & maintain `assets/data/`:
  - `jatim_kecamatan.csv` — direktori kecamatan/kabupaten Jatim
  - `kendaraan_jatim.csv`, `njkb_database.csv` — Bapenda
  - `kamar_*.csv`, `jadwal_*.csv`, `antrean_*.csv` — 4 RSUD
  - `penerima_bansos.csv` — Sapa Bansos
- Extend jadwal operasi 4 RSUD ke 31 Mei 2026
- `DatasetDownloadService` — generate CSV (RFC 4180) dari dataset Open Data, save ke `getTemporaryDirectory()`, share via system sheet

#### H. Backend Node.js (Sekunder)
- `backend/src/server.js` — Express app dengan CORS allowlist
- Routes `/api/auth` — register, login, password reset (Mongoose + MongoDB)
- bcryptjs untuk password hashing, nodemailer untuk email
- Health check `/health`

### Deliverables Farhan
- Service classes di `lib/auth_service.dart`, `lib/notification_service.dart`, `lib/common/*`, `lib/beranda/*service.dart`, `lib/transjatim/transjatim_ticket_service.dart`, `lib/admin/audit_log_service.dart`
- `lib/personalization_rule_base.dart` — rule engine
- Firestore Security Rules + Firebase Storage Rules
- CSV data lengkap di `assets/data/`
- Backend Node.js di `backend/src/`

---

## 2. Ghairan — Front-End Developer

### Tanggung Jawab Utama
Membangun seluruh UI/UX aplikasi: layout pages, widgets, navigation, theme, animasi, dan accessibility. Memastikan tampilan konsisten, responsif, mengikuti design system, dan memberikan UX yang smooth.

### Scope Pekerjaan

#### A. Design System & Theme
- `AppTheme` (`lib/theme/app_theme.dart`) — palet warna terpusat, helper context-aware (`backgroundOf`, `surfaceOf`, `textPrimaryOf`) untuk light & dark mode
- `ThemeController` & `FontScaleController` — `ValueNotifier<ThemeMode>` & `<FontScaleOption>` dengan persistence di SharedPreferences
- Tipografi PlusJakartaSans (Regular / Medium / SemiBold / Bold)

#### B. Routing & Navigation
- `AppRoutes.generateRoute` (`lib/app_route.dart`) — 40+ route terpusat
- Custom transitions: `FadePageRoute` (untuk halaman tumpuk) & `SlidePageRoute` (default)
- `HeroTags` — Hero animation untuk profile avatar & service card
- Lazy loading via `import deferred as` untuk fitur addable + `DeferredFeaturePage` wrapper

#### C. Auth & Onboarding Flow
- `SplashScreen`, `OnboardingPage` (3 slide)
- `LoginPage`, `RegisterPage` (dengan strength meter), `VerifyEmailPage`, `ForgetPasswordPage`, `EmailSentPage`
- `PersonalizationLocationPage` (GPS + manual link) → `LocationManualPage` (search dengan score-based ranking) → `PersonalizationServicesPage` (multi-select kategori) → `PersonalizationSuccessPage`

#### D. Beranda (Hub Utama)
- Header dengan avatar, lokasi clickable, notif badge
- Search bar global, welcome banner, akses cepat shortcut
- **Layanan Unggulan grid** dengan AnimatedSwitcher fade saat list berubah
- **Bottom sheet location picker** (GPS / Manual) dengan smooth refresh
- Berita & Artikel section + tombol "Lihat Semua"
- `BeritaArsipPage` — filter chip per kategori
- Maja AI floating bubble + speech tail
- Bottom navigation (Beranda / Favorit / Profil)

#### E. Maja AI Chat UI
- `MajaAiChatPage` — header dengan greeting time-aware
- **Streaming bubble** (chunk-by-chunk update saat respons Gemini masuk)
- **Loading pill** & **Stop Merespon** button saat streaming
- Suggestion chip dinamis di empty state
- Long-press copy + dialog konfirmasi clear history

#### F. Fitur Core (5 Layanan Unggulan)
- **Bapenda**: tab Layanan/Informasi, form Info Pajak, form Estimasi NJKB, halaman hasil dengan card detail
- **RSUD**: 4 RS dengan accordion Operasional & Ketentuan, halaman Kamar (table), Jadwal Operasi (filter tanggal + chips klinik), Antrean (filter poli + ETA visual)
- **Transjatim**: 4 tab (Beli Tiket, Rute, Peta, Riwayat), `BuyTicketPage`, `PaymentPage`, `TicketResultPage` (QR + dashed divider + watermark **TERPAKAI** saat used)
- **Siskaperbapo**: search bar, kabupaten chips horizontal, sembako card grid, detail dengan grafik tren (`PriceGraphPainter`)
- **Nomor Darurat**: cari nomor + informasi

#### G. Fitur Addable (Deferred)
- **Sapa Bansos** — 3 tab (Penerima form, Program list, Tentang)
- **Etibi** — 3 tab (Skrining kuesioner, Riwayat, Tentang TBC)
- **Klinik Hoaks** — landing form (3 field wajib + file picker) dengan **penanda asterisk merah** + legenda; permohonan page (Tiket Saya + Riwayat); detail sheet
- **Open Data** — landing, list, 9 detail page (Penduduk, Kemiskinan, IPM, APBD, Faskes, Pariwisata, Inflasi, Infrastruktur, TPT), Sebaran UMKM, Dapur MBG, Ayo Pasok

#### H. Profil & Admin
- `ProfilTab` — streak banner, statistik bulan ini, aktivitas terakhir, menu akun
- `UbahProfilPage`, `KeamananAkunPage` (form + biometric toggle), `AksesibilitasPage` (tema + font scale), `LencanaPage`
- `AdminPage` — filter chip status, list laporan dengan badge, detail draggable bottom sheet
- `AdminNotifikasiPage`, `AuditLogPage`
- **`ScanTiketPage`** — TabBar Kamera / Manual, MobileScanner overlay frame + tombol senter, result bottom sheet (success / alreadyUsed / notFound / error) dengan ikon & detail tiket

#### I. Reusable Widgets
- `EmptyState`, `ErrorRetry`, `SkeletonLoader.list/dashboard`, `PasswordStrengthMeter`
- Custom widgets per fitur: `RouteCard`, `HalteMapWidget`, `TimelineGraph`, `SembakoCard`, `IndicatorBadge`, `InfoCard`, `PriceGraphPainter`, `ProgramCard`

#### J. Accessibility & UX Polish
- `Semantics()` widget di tombol & elemen interaktif (label + hint)
- `ExcludeSemantics` untuk dekorasi
- `AnimatedSwitcher`, `AnimatedContainer`, Hero animation
- Skeleton loaders, EmptyState fallback, ErrorRetry boundaries
- Light/dark mode + 3 skala font (small/normal/large)

### Deliverables Ghairan
- Semua page di `lib/` (~70+ file `.dart` UI)
- `lib/theme/` (3 file)
- `lib/widgets/` (4 reusable widgets)
- Custom widgets per fitur di `lib/<feature>/widgets/`
- Routing & transitions di `lib/app_route.dart` & `lib/app_transitions.dart`

---

## 3. Faris — Testing Fitur

### Tanggung Jawab Utama
Menjalankan skenario pengujian end-to-end, menemukan & melaporkan bug, memvalidasi perbaikan (regression testing), dan menyusun dokumentasi QA. Memastikan setiap fitur memenuhi acceptance criteria sebelum rilis.

### Scope Pekerjaan

#### A. Test Planning & Skenario Uji
Menyusun matriks skenario uji per fitur, lengkap dengan:
- Tujuan uji
- Langkah-langkah
- Hasil yang diharapkan
- Status (Lulus / Gagal) + catatan

#### B. Manual Testing per Fitur

**Auth & Onboarding**
- Register dengan field tidak valid → tombol disabled
- Register dengan password & konfirmasi berbeda → tombol disabled
- Email verification flow + resend cooldown
- Login dengan credentials salah → error mapping benar

**Personalisasi**
- Detect GPS → auto-fill lokasi
- Manual location search dengan keyword berbagai
- Pilih kategori → 5 layanan unggulan tepat sesuai rule

**Beranda**
- Tap header lokasi → bottom sheet muncul → ganti lokasi → RSUD ikut refresh
- Tap "Lihat Semua" Berita → halaman arsip + filter
- Search global lintas fitur

**Bapenda**
- Cek pajak dengan plat valid/invalid
- Estimasi NJKB dropdown chain (jenis → merk → tipe)

**RSUD**
- Filter jadwal operasi by tanggal — pastikan tanggal di luar data ter-disable
- Filter klinik & search nama operasi
- Antrean: filter poli + ETA tampil

**Transjatim**
- End-to-end flow: pilih rute → pilih kursi → bayar → QR muncul
- Buka Riwayat → tap card → QR tampil ulang
- **One-shot ticket**: scan oleh admin → status = `used` → user buka tiket lagi → banner peringatan + watermark TERPAKAI

**Siskaperbapo**
- Filter kabupaten → harga di card berubah sesuai rata-rata kabupaten
- Tab tren bulanan tampil grafik

**Klinik Hoaks**
- Form: tombol Ajukan disabled saat field wajib kosong
- **Field wajib (* merah) terlihat berbeda dari opsional**
- Upload file format & ukuran sesuai (≤ 10 MB)
- Dokumen masuk Firestore + Storage URL valid
- Status update flow: Diproses → Diverifikasi → Selesai

**Open Data**
- Tap Unduh Dataset → file CSV ter-download (system share sheet)
- Validasi struktur CSV (header + rows benar)

**Maja AI**
- Streaming bubble jalan
- Tombol Stop berfungsi
- Rate limit: 9 pesan beruntun → SnackBar "tunggu N detik"
- Clear history → konfirmasi → riwayat terhapus

**Profil & Admin**
- Ganti password — validasi old/new/confirm
- Toggle biometric — prompt fingerprint/face
- Aksesibilitas: tema dark mode + font besar/kecil → tampilan konsisten
- Admin Scan Tiket: kamera & manual mode, semua 4 outcome state (success/alreadyUsed/notFound/error)

#### C. Bug Discovery (Yang Ditemukan & Dilaporkan)
| # | Fitur | Bug | Status |
|---|---|---|---|
| 1 | Register | Tombol Daftar tetap aktif walau confirm password berbeda | ✅ Fixed |
| 2 | Keamanan Akun | Tombol Simpan tidak cek validitas form | ✅ Fixed |
| 3 | Jadwal Operasi RSUD | Filter tanggal selalu kosong (date di luar data CSV) | ✅ Fixed |
| 4 | Siskaperbapo | Harga di card tidak berubah saat ganti kabupaten | ✅ Fixed |
| 5 | Open Data | Tombol Unduh Dataset hanya buka browser, bukan download | ✅ Fixed |
| 6 | Klinik Hoaks Form | Tidak terlihat penanda field wajib vs opsional | ✅ Fixed |
| 7 | Klinik Hoaks Upload | Laporan dengan file gagal terkirim | ✅ Fixed |
| 8 | Beranda Berita | Tombol "Lihat Semua" tidak bekerja | ✅ Fixed |
| 9 | Transjatim Riwayat | QR tidak bisa ditampilkan ulang setelah bayar | ✅ Fixed |

#### D. Regression Testing
- Verifikasi tiap fix tidak mem-break fitur lain
- Spot check setelah tiap commit penting (`flutter analyze` bersih)
- Cross-check dark mode + font scaling masih konsisten

#### E. Edge Cases & Validation
- Offline mode — fallback ke cache (ProfileCache, local SharedPreferences)
- Empty states (belum ada laporan, belum ada tiket, dll.)
- File size limits (Klinik Hoaks 10 MB, foto profil 5 MB)
- Permission flows: lokasi (GPS), kamera (scan), biometric, notifikasi
- Network error handling (Firestore timeout, Gemini API error)

#### F. Cross-Device & Compatibility
- Android berbagai versi (min SDK 21+)
- Light mode & dark mode di semua page
- Font scale small / normal / large — layout tidak rusak

#### G. Dokumentasi
- `modul_sistem.md` — ~92 modul dengan kolom Modul / Fungsi / Input / Output
- `arsitektur_sistem.svg` — diagram arsitektur tingkat tinggi
- `alur_sistem.svg` — diagram alur user journey 6 fase
- `pembagian_tugas.md` — dokumen ini
- Skenario uji per fitur (test cases)
- Bug report log

### Deliverables Faris
- Test case document (skenario uji)
- Bug report tracker
- Acceptance test result
- Dokumentasi capstone: `modul_sistem.md`, `arsitektur_sistem.svg`, `alur_sistem.svg`, `pembagian_tugas.md`

---

## Matrix Fitur → Tim

Tabel kontribusi per fitur (✓ = berkontribusi, ⚪ = tidak terlibat).

| Fitur | Backend (Farhan) | Front-End (Ghairan) | Testing (Faris) |
|---|:---:|:---:|:---:|
| Splash, Onboarding, Auth, Verify | ✓ | ✓ | ✓ |
| Personalisasi (Lokasi, Kategori) | ✓ | ✓ | ✓ |
| Beranda Hub + Location Picker | ✓ | ✓ | ✓ |
| Bapenda (Pajak Kendaraan) | ✓ | ✓ | ✓ |
| RSUD (4 hospitals) | ✓ | ✓ | ✓ |
| Transjatim Beli/Bayar/Riwayat | ✓ | ✓ | ✓ |
| Transjatim Scan Admin (one-shot) | ✓ | ✓ | ✓ |
| Siskaperbapo (Harga Bahan) | ✓ | ✓ | ✓ |
| Etibi (Skrining TBC) | ✓ | ✓ | ✓ |
| Sapa Bansos | ✓ | ✓ | ✓ |
| Klinik Hoaks (form + upload) | ✓ | ✓ | ✓ |
| Open Data (9 dataset + sebaran) | ✓ | ✓ | ✓ |
| Nomor Darurat | ⚪ | ✓ | ✓ |
| Berita & Artikel + Arsip | ⚪ | ✓ | ✓ |
| Maja AI Chat (Gemini) | ✓ | ✓ | ✓ |
| Profil + Streak + Lencana | ✓ | ✓ | ✓ |
| Admin Panel + Audit Log | ✓ | ✓ | ✓ |
| Theme & Aksesibilitas | ⚪ | ✓ | ✓ |
| Backend Node + MongoDB | ✓ | ⚪ | ⚪ |

---

## Tools & Tech Stack per Role

### Farhan (Backend)
- **Cloud**: Firebase (Auth, Firestore, Storage, FCM), Google Cloud (Gemini API)
- **Server**: Node.js + Express, MongoDB + Mongoose, bcryptjs, nodemailer
- **Flutter packages**: `cloud_firestore`, `firebase_auth`, `firebase_storage`, `firebase_messaging`, `google_generative_ai`, `geolocator`, `geocoding`, `csv`, `path_provider`, `shared_preferences`, `local_auth`
- **Tools**: Firebase Console (rules, monitoring), Postman (REST testing)

### Ghairan (Front-End)
- **Framework**: Flutter ^3.11, Dart
- **Flutter packages**: `flutter_svg`, `cached_network_image`, `flutter_map` + `latlong2`, `qr_flutter`, `image_picker`, `image_cropper`, `file_picker`, `share_plus`, `url_launcher`, `flutter_local_notifications`, `mobile_scanner`
- **Design**: PlusJakartaSans typography, custom design system di `AppTheme`
- **Tools**: Flutter DevTools, Hot Reload, Android Studio / VS Code

### Faris (Testing)
- **Manual testing**: Android emulator + physical device
- **Static analysis**: `flutter analyze` (lint check)
- **Documentation**: Markdown + draw.io / Excalidraw / SVG (diagram)
- **Tracking**: Test case spreadsheet, bug log
- **Tools**: Firebase Console (verify data), Logcat, Charles/network inspector

---

## Ringkasan

| Aspek | Backend (Farhan) | Front-End (Ghairan) | Testing (Faris) |
|---|---|---|---|
| **Output utama** | Service classes, Firebase rules, data CSV, backend Node | Pages, widgets, theme, animation | Test cases, bug reports, dokumentasi |
| **File utama** | `lib/auth_service.dart`, `lib/personalization_rule_base.dart`, `lib/<feature>/*service.dart`, `assets/data/`, `backend/src/` | `lib/<feature>/*page.dart`, `lib/theme/`, `lib/widgets/`, `lib/app_route.dart` | `modul_sistem.md`, `arsitektur_sistem.svg`, `alur_sistem.svg`, `pembagian_tugas.md` |
| **Kontribusi LoC** | ~40% | ~50% | ~10% (dokumentasi) |
| **Tools utama** | Firebase, Gemini, MongoDB, Node | Flutter, Material, custom widgets | Android device, flutter analyze, Markdown |

---

*Dokumen ini dibuat untuk capstone Majadigi sebagai pelengkap `modul_sistem.md`, `arsitektur_sistem.svg`, dan `alur_sistem.svg`.*
