import 'package:flutter/material.dart';
import '../data/sapabansos_dummy_data.dart';
import '../models/sapabansos_model.dart';
import '../program_detail_page.dart';
import 'program_card.dart';

class ProgramTab extends StatefulWidget {
  const ProgramTab({super.key});

  @override
  State<ProgramTab> createState() => _ProgramTabState();
}

class _ProgramTabState extends State<ProgramTab> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);

  String _selectedKategori = 'Semua';

  List<BansosProgram> get _filtered => _selectedKategori == 'Semua'
      ? SapaBansosData.programs
      : SapaBansosData.programs.where((p) => p.kategori == _selectedKategori).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterChips(),
        const SizedBox(height: 16),
        ..._filtered.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProgramDetailPage(program: p)),
                ),
                child: ProgramCard(program: p),
              ),
            )),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: SapaBansosData.kategoriList.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final k = SapaBansosData.kategoriList[i];
          final selected = k == _selectedKategori;
          return GestureDetector(
            onTap: () => setState(() => _selectedKategori = k),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? _blue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _blue : const Color(0xFFDDDDDD),
                ),
              ),
              child: Text(
                k,
                style: TextStyle(
                  color: selected ? Colors.white : _textPrimary,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
