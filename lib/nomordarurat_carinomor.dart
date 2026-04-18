import 'package:flutter/material.dart';

class NomorDaruratCariNomorPage extends StatefulWidget {
  const NomorDaruratCariNomorPage({super.key});

  @override
  State<NomorDaruratCariNomorPage> createState() => _NomorDaruratCariNomorPageState();
}

class _NomorDaruratCariNomorPageState extends State<NomorDaruratCariNomorPage> {
  String _selectedDaerah = 'Jawa Timur';
  final List<String> _daerahList = ['Jawa Timur', 'Kota Batu', 'Surabaya', 'Malang', 'Sidoarjo'];

  // Mapping of contact data
  final Map<String, List<Map<String, String>>> _contactData = {
    'Jawa Timur': [
      {'title': 'AMBULANS / DARURAT', 'number': '112'},
      {'title': 'POLDA JATIM', 'number': '(031) 8280748'},
      {'title': 'CALL CENTER', 'number': '1500979'},
    ],
    'Kota Batu': [
      {'title': 'POLSEK BATU', 'number': '0341 591110'},
      {'title': 'DINAS PEMADAM KEBAKARAN', 'number': '0811 3114 9113'},
      {'title': 'LAKA LANTAS', 'number': '0341 512266'},
    ],
  };

  // State for expanded cards
  final Set<String> _expandedTitles = {};

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> contacts = _contactData[_selectedDaerah] ?? _contactData['Jawa Timur']!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Header Background
          Container(
            width: double.infinity,
            height: 250,
            decoration: const BoxDecoration(
              color: Color(0xFF007AFF),
              image: DecorationImage(
                image: AssetImage('assets/images/header_texture.png'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
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
                // Header Bar
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
                // Content Area
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 12),
                            // Custom Dropdown
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
                                  items: _daerahList.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedDaerah = newValue!;
                                      _expandedTitles.clear(); // Close all when region changes
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
                            // Contacts List
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: contacts.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final contact = contacts[index];
                                final isExpanded = _expandedTitles.contains(contact['title']);
                                return _buildContactCard(
                                  title: contact['title']!,
                                  number: contact['number']!,
                                  isExpanded: isExpanded,
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedTitles.remove(contact['title']);
                                      } else {
                                        _expandedTitles.add(contact['title']!);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
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

  Widget _buildContactCard({
    required String title,
    required String number,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFEBF5FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_in_talk, color: Color(0xFF007AFF), size: 24),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            subtitle: Text(
              number,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'PlusJakartaSans',
                color: Colors.grey,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: const Color(0xFF007AFF),
                size: 20,
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF1744), // Red like image
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Hubungi Sekarang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlusJakartaSans',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
