import 'package:flutter/material.dart';
import '../data/sapabansos_dummy_data.dart';
import 'program_card.dart';

class ProgramTab extends StatelessWidget {
  const ProgramTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        SapaBansosDummyData.programs.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ProgramCard(program: SapaBansosDummyData.programs[index]),
        ),
      ),
    );
  }
}
