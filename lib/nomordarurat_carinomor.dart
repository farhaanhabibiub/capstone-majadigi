import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_service.dart';

class NomorDaruratCariNomorPage extends StatefulWidget {
  const NomorDaruratCariNomorPage({super.key});

  @override
  State<NomorDaruratCariNomorPage> createState() => _NomorDaruratCariNomorPageState();
}

class _NomorDaruratCariNomorPageState extends State<NomorDaruratCariNomorPage> {
  String _selectedDaerah = 'Jawa Timur';
  bool _locationLoaded = false;

  final List<String> _daerahList = [
    'Jawa Timur',
    'Kab. Bangkalan',
    'Kab. Banyuwangi',
    'Kab. Blitar',
    'Kab. Bojonegoro',
    'Kab. Bondowoso',
    'Kab. Gresik',
    'Kab. Jember',
    'Kab. Jombang',
    'Kab. Kediri',
    'Kab. Lamongan',
    'Kab. Lumajang',
    'Kab. Madiun',
    'Kab. Magetan',
    'Kab. Malang',
    'Kab. Mojokerto',
    'Kab. Nganjuk',
    'Kab. Ngawi',
    'Kab. Pacitan',
    'Kab. Pamekasan',
    'Kab. Pasuruan',
    'Kab. Ponorogo',
    'Kab. Probolinggo',
    'Kab. Sampang',
    'Kab. Sidoarjo',
    'Kab. Situbondo',
    'Kab. Sumenep',
    'Kab. Trenggalek',
    'Kab. Tuban',
    'Kab. Tulungagung',
    'Kota Batu',
    'Kota Blitar',
    'Kota Kediri',
    'Kota Madiun',
    'Kota Malang',
    'Kota Mojokerto',
    'Kota Pasuruan',
    'Kota Probolinggo',
    'Kota Surabaya',
  ];

  final Map<String, List<Map<String, String>>> _contactData = {
    'Jawa Timur': [
      {'title': 'DARURAT NASIONAL', 'number': '112'},
      {'title': 'POLISI', 'number': '110'},
      {'title': 'AMBULANS NASIONAL', 'number': '119'},
      {'title': 'PEMADAM KEBAKARAN', 'number': '113'},
      {'title': 'SAR NASIONAL', 'number': '115'},
      {'title': 'POLDA JATIM', 'number': '(031) 8280748'},
      {'title': 'CALL CENTER JATIM', 'number': '1500979'},
      {'title': 'BPBD JATIM', 'number': '(031) 8290122'},
    ],
    'Kab. Bangkalan': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES BANGKALAN', 'number': '(031) 3095110'},
      {'title': 'DAMKAR BANGKALAN', 'number': '(031) 3096113'},
      {'title': 'RSUD BANGKALAN', 'number': '(031) 3095074'},
      {'title': 'BPBD BANGKALAN', 'number': '(031) 3096190'},
    ],
    'Kab. Banyuwangi': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES BANYUWANGI', 'number': '(0333) 410110'},
      {'title': 'DAMKAR BANYUWANGI', 'number': '(0333) 413113'},
      {'title': 'RSUD BLAMBANGAN', 'number': '(0333) 421118'},
      {'title': 'BPBD BANYUWANGI', 'number': '(0333) 411114'},
    ],
    'Kab. Blitar': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES BLITAR', 'number': '(0342) 801110'},
      {'title': 'DAMKAR BLITAR', 'number': '(0342) 801113'},
      {'title': 'RSUD NGUDI WALUYO', 'number': '(0342) 801066'},
      {'title': 'BPBD BLITAR', 'number': '(0342) 808119'},
    ],
    'Kab. Bojonegoro': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES BOJONEGORO', 'number': '(0353) 881110'},
      {'title': 'DAMKAR BOJONEGORO', 'number': '(0353) 881113'},
      {'title': 'RSUD SOSODORO', 'number': '(0353) 881040'},
      {'title': 'BPBD BOJONEGORO', 'number': '(0353) 889119'},
    ],
    'Kab. Bondowoso': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES BONDOWOSO', 'number': '(0332) 421110'},
      {'title': 'DAMKAR BONDOWOSO', 'number': '(0332) 422113'},
      {'title': 'RSUD BONDOWOSO', 'number': '(0332) 421174'},
      {'title': 'BPBD BONDOWOSO', 'number': '(0332) 424119'},
    ],
    'Kab. Gresik': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES GRESIK', 'number': '(031) 3981110'},
      {'title': 'DAMKAR GRESIK', 'number': '(031) 3982113'},
      {'title': 'RSUD IBNU SINA', 'number': '(031) 3981570'},
      {'title': 'BPBD GRESIK', 'number': '(031) 3971119'},
    ],
    'Kab. Jember': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES JEMBER', 'number': '(0331) 487110'},
      {'title': 'DAMKAR JEMBER', 'number': '(0331) 487113'},
      {'title': 'RSUD DR. SOEBANDI', 'number': '(0331) 487564'},
      {'title': 'BPBD JEMBER', 'number': '(0331) 489119'},
    ],
    'Kab. Jombang': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES JOMBANG', 'number': '(0321) 861110'},
      {'title': 'DAMKAR JOMBANG', 'number': '(0321) 861113'},
      {'title': 'RSUD JOMBANG', 'number': '(0321) 866060'},
      {'title': 'BPBD JOMBANG', 'number': '(0321) 868119'},
    ],
    'Kab. Kediri': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES KEDIRI', 'number': '(0354) 682110'},
      {'title': 'DAMKAR KEDIRI', 'number': '(0354) 682113'},
      {'title': 'RSUD PARE', 'number': '(0354) 391718'},
      {'title': 'BPBD KEDIRI', 'number': '(0354) 689119'},
    ],
    'Kab. Lamongan': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES LAMONGAN', 'number': '(0322) 321110'},
      {'title': 'DAMKAR LAMONGAN', 'number': '(0322) 321113'},
      {'title': 'RSUD LAMONGAN', 'number': '(0322) 321820'},
      {'title': 'BPBD LAMONGAN', 'number': '(0322) 325119'},
    ],
    'Kab. Lumajang': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES LUMAJANG', 'number': '(0334) 881110'},
      {'title': 'DAMKAR LUMAJANG', 'number': '(0334) 881113'},
      {'title': 'RSUD DR. HARYOTO', 'number': '(0334) 881666'},
      {'title': 'BPBD LUMAJANG', 'number': '(0334) 884119'},
    ],
    'Kab. Madiun': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES MADIUN', 'number': '(0351) 384110'},
      {'title': 'DAMKAR MADIUN', 'number': '(0351) 384113'},
      {'title': 'RSUD CARUBAN', 'number': '(0351) 381046'},
      {'title': 'BPBD MADIUN', 'number': '(0351) 388119'},
    ],
    'Kab. Magetan': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES MAGETAN', 'number': '(0351) 895110'},
      {'title': 'DAMKAR MAGETAN', 'number': '(0351) 895113'},
      {'title': 'RSUD MAGETAN', 'number': '(0351) 895023'},
      {'title': 'BPBD MAGETAN', 'number': '(0351) 898119'},
    ],
    'Kab. Malang': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES MALANG', 'number': '(0341) 391110'},
      {'title': 'DAMKAR MALANG', 'number': '(0341) 391113'},
      {'title': 'RSUD KANJURUHAN', 'number': '(0341) 393024'},
      {'title': 'BPBD MALANG', 'number': '(0341) 396119'},
    ],
    'Kab. Mojokerto': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES MOJOKERTO', 'number': '(0321) 321110'},
      {'title': 'DAMKAR MOJOKERTO', 'number': '(0321) 321113'},
      {'title': 'RSUD RA BASOENI', 'number': '(0321) 365222'},
      {'title': 'BPBD MOJOKERTO', 'number': '(0321) 326119'},
    ],
    'Kab. Nganjuk': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES NGANJUK', 'number': '(0358) 321110'},
      {'title': 'DAMKAR NGANJUK', 'number': '(0358) 321113'},
      {'title': 'RSUD NGANJUK', 'number': '(0358) 321010'},
      {'title': 'BPBD NGANJUK', 'number': '(0358) 326119'},
    ],
    'Kab. Ngawi': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES NGAWI', 'number': '(0351) 749110'},
      {'title': 'DAMKAR NGAWI', 'number': '(0351) 749113'},
      {'title': 'RSUD DR. SOEROTO', 'number': '(0351) 749024'},
      {'title': 'BPBD NGAWI', 'number': '(0351) 745119'},
    ],
    'Kab. Pacitan': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES PACITAN', 'number': '(0357) 881110'},
      {'title': 'DAMKAR PACITAN', 'number': '(0357) 881113'},
      {'title': 'RSUD PACITAN', 'number': '(0357) 881198'},
      {'title': 'BPBD PACITAN', 'number': '(0357) 884119'},
    ],
    'Kab. Pamekasan': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES PAMEKASAN', 'number': '(0324) 321110'},
      {'title': 'DAMKAR PAMEKASAN', 'number': '(0324) 321113'},
      {'title': 'RSUD PAMEKASAN', 'number': '(0324) 322191'},
      {'title': 'BPBD PAMEKASAN', 'number': '(0324) 325119'},
    ],
    'Kab. Pasuruan': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES PASURUAN', 'number': '(0343) 421110'},
      {'title': 'DAMKAR PASURUAN', 'number': '(0343) 421113'},
      {'title': 'RSUD BANGIL', 'number': '(0343) 741024'},
      {'title': 'BPBD PASURUAN', 'number': '(0343) 426119'},
    ],
    'Kab. Ponorogo': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES PONOROGO', 'number': '(0352) 481110'},
      {'title': 'DAMKAR PONOROGO', 'number': '(0352) 481113'},
      {'title': 'RSUD DR. HARJONO', 'number': '(0352) 481218'},
      {'title': 'BPBD PONOROGO', 'number': '(0352) 485119'},
    ],
    'Kab. Probolinggo': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES PROBOLINGGO', 'number': '(0335) 421110'},
      {'title': 'DAMKAR PROBOLINGGO', 'number': '(0335) 421113'},
      {'title': 'RSUD TONGAS', 'number': '(0335) 511049'},
      {'title': 'BPBD PROBOLINGGO', 'number': '(0335) 426119'},
    ],
    'Kab. Sampang': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES SAMPANG', 'number': '(0323) 321110'},
      {'title': 'DAMKAR SAMPANG', 'number': '(0323) 321113'},
      {'title': 'RSUD SAMPANG', 'number': '(0323) 322176'},
      {'title': 'BPBD SAMPANG', 'number': '(0323) 325119'},
    ],
    'Kab. Sidoarjo': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES SIDOARJO', 'number': '(031) 8941110'},
      {'title': 'DAMKAR SIDOARJO', 'number': '(031) 8941113'},
      {'title': 'RSUD SIDOARJO', 'number': '(031) 8962721'},
      {'title': 'BPBD SIDOARJO', 'number': '(031) 8963119'},
    ],
    'Kab. Situbondo': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES SITUBONDO', 'number': '(0338) 671110'},
      {'title': 'DAMKAR SITUBONDO', 'number': '(0338) 671113'},
      {'title': 'RSUD ABDOER RAHEM', 'number': '(0338) 671082'},
      {'title': 'BPBD SITUBONDO', 'number': '(0338) 675119'},
    ],
    'Kab. Sumenep': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES SUMENEP', 'number': '(0328) 662110'},
      {'title': 'DAMKAR SUMENEP', 'number': '(0328) 662113'},
      {'title': 'RSUD DR. H. MOH. ANWAR', 'number': '(0328) 662170'},
      {'title': 'BPBD SUMENEP', 'number': '(0328) 665119'},
    ],
    'Kab. Trenggalek': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES TRENGGALEK', 'number': '(0355) 791110'},
      {'title': 'DAMKAR TRENGGALEK', 'number': '(0355) 791113'},
      {'title': 'RSUD DR. SOEDOMO', 'number': '(0355) 791118'},
      {'title': 'BPBD TRENGGALEK', 'number': '(0355) 795119'},
    ],
    'Kab. Tuban': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES TUBAN', 'number': '(0356) 321110'},
      {'title': 'DAMKAR TUBAN', 'number': '(0356) 321113'},
      {'title': 'RSUD DR. R. KOESMA', 'number': '(0356) 321010'},
      {'title': 'BPBD TUBAN', 'number': '(0356) 325119'},
    ],
    'Kab. Tulungagung': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES TULUNGAGUNG', 'number': '(0355) 321110'},
      {'title': 'DAMKAR TULUNGAGUNG', 'number': '(0355) 321113'},
      {'title': 'RSUD DR. ISKAK', 'number': '(0355) 322399'},
      {'title': 'BPBD TULUNGAGUNG', 'number': '(0355) 326119'},
    ],
    'Kota Batu': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRES BATU', 'number': '(0341) 591110'},
      {'title': 'DAMKAR BATU', 'number': '0811 3114 9113'},
      {'title': 'RSUD BATU', 'number': '(0341) 591076'},
      {'title': 'LAKA LANTAS', 'number': '(0341) 512266'},
    ],
    'Kota Blitar': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRESTA BLITAR', 'number': '(0342) 801110'},
      {'title': 'DAMKAR BLITAR', 'number': '(0342) 801113'},
      {'title': 'RSUD MARDI WALUYO', 'number': '(0342) 801066'},
      {'title': 'BPBD BLITAR', 'number': '(0342) 805119'},
    ],
    'Kota Kediri': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRESTA KEDIRI', 'number': '(0354) 682110'},
      {'title': 'DAMKAR KEDIRI', 'number': '(0354) 682113'},
      {'title': 'RSUD GAMBIRAN', 'number': '(0354) 682693'},
      {'title': 'BPBD KEDIRI', 'number': '(0354) 686119'},
    ],
    'Kota Madiun': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRESTA MADIUN', 'number': '(0351) 452110'},
      {'title': 'DAMKAR MADIUN', 'number': '(0351) 452113'},
      {'title': 'RSUD SOGATEN', 'number': '(0351) 453536'},
      {'title': 'BPBD MADIUN', 'number': '(0351) 456119'},
    ],
    'Kota Malang': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRESTA MALANG', 'number': '(0341) 491110'},
      {'title': 'DAMKAR MALANG', 'number': '(0341) 362121'},
      {'title': 'RSUD DR. SAIFUL ANWAR', 'number': '(0341) 362101'},
      {'title': 'BPBD MALANG', 'number': '(0341) 365119'},
    ],
    'Kota Mojokerto': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRESTA MOJOKERTO', 'number': '(0321) 321110'},
      {'title': 'DAMKAR MOJOKERTO', 'number': '(0321) 321113'},
      {'title': 'RSUD DR. WAHIDIN', 'number': '(0321) 321005'},
      {'title': 'BPBD MOJOKERTO', 'number': '(0321) 325119'},
    ],
    'Kota Pasuruan': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRESTA PASURUAN', 'number': '(0343) 421110'},
      {'title': 'DAMKAR PASURUAN', 'number': '(0343) 421113'},
      {'title': 'RSUD R. SOEDARSONO', 'number': '(0343) 421118'},
      {'title': 'BPBD PASURUAN', 'number': '(0343) 425119'},
    ],
    'Kota Probolinggo': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRESTA PROBOLINGGO', 'number': '(0335) 421110'},
      {'title': 'DAMKAR PROBOLINGGO', 'number': '(0335) 421113'},
      {'title': 'RSUD DR. MOHAMAD SALEH', 'number': '(0335) 422118'},
      {'title': 'BPBD PROBOLINGGO', 'number': '(0335) 425119'},
    ],
    'Kota Surabaya': [
      {'title': 'DARURAT', 'number': '112'},
      {'title': 'POLRESTABES SURABAYA', 'number': '(031) 3523927'},
      {'title': 'DAMKAR SURABAYA', 'number': '(031) 3523928'},
      {'title': 'RSUD DR. SOETOMO', 'number': '(031) 5501078'},
      {'title': 'BPBD SURABAYA', 'number': '(031) 5456999'},
      {'title': 'PMI SURABAYA', 'number': '(031) 5345943'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadUserDaerah();
  }

  Future<void> _loadUserDaerah() async {
    final profile = await AuthService.instance.getUserProfile();
    if (!mounted) return;
    final location = profile?['location'] as Map<String, dynamic>?;
    final regency = (location?['regency'] as String?)?.trim() ?? '';
    if (regency.isEmpty) {
      setState(() => _locationLoaded = true);
      return;
    }

    final matched = _matchDaerah(regency);
    setState(() {
      _selectedDaerah = matched;
      _locationLoaded = true;
    });
  }

  String _matchDaerah(String regency) {
    final query = regency.toLowerCase()
        .replaceFirst(RegExp(r'^(kabupaten |kota )'), '');

    for (final daerah in _daerahList) {
      final name = daerah.toLowerCase()
          .replaceFirst(RegExp(r'^(kab\. |kota )'), '');
      if (name == query || name.contains(query) || query.contains(name)) {
        return daerah;
      }
    }
    return 'Jawa Timur';
  }

  Future<void> _launchPhone(String number) async {
    final cleaned = number.replaceAll(RegExp(r'[\s\-()]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak dapat membuka aplikasi telepon untuk nomor $number',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
            ),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = _contactData[_selectedDaerah] ?? _contactData['Jawa Timur']!;

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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Text(
                          'Cari Nomor Darurat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
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
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Nama Daerah',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'PlusJakartaSans',
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  if (!_locationLoaded)
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF007AFF),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEBF5FF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.location_on_rounded,
                                              color: Color(0xFF007AFF), size: 12),
                                          const SizedBox(width: 3),
                                          const Text(
                                            'Lokasi kamu',
                                            style: TextStyle(
                                              color: Color(0xFF007AFF),
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF007AFF),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedDaerah,
                                    icon: const Icon(Icons.expand_more, color: Colors.white),
                                    dropdownColor: const Color(0xFF007AFF),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'PlusJakartaSans',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    items: _daerahList.map((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedDaerah = newValue!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Daftar Nomor Kontak',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'PlusJakartaSans',
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                            itemCount: contacts.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final contact = contacts[index];
                              return _buildContactCard(
                                title: contact['title']!,
                                number: contact['number']!,
                              );
                            },
                          ),
                        ),
                      ],
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

  Widget _buildContactCard({required String title, required String number}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _launchPhone(number),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF5FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_in_talk, color: Color(0xFF007AFF), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF1744),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
