import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/font_scale_controller.dart';
import '../theme/theme_controller.dart';

class AksesibilitasPage extends StatefulWidget {
  const AksesibilitasPage({super.key});

  @override
  State<AksesibilitasPage> createState() => _AksesibilitasPageState();
}

class _AksesibilitasPageState extends State<AksesibilitasPage> {
  bool _isDark = ThemeController.isDark;
  FontScaleOption _fontOption = FontScaleController.current;

  Future<void> _toggleDark(bool value) async {
    await ThemeController.setDark(value);
    setState(() => _isDark = value);
  }

  Future<void> _selectFont(FontScaleOption option) async {
    await FontScaleController.set(option);
    setState(() => _fontOption = option);
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.backgroundOf(context);
    final surface = AppTheme.surfaceOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Aksesibilitas',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _sectionLabel('Tampilan', textSecondary),
          const SizedBox(height: 8),
          Semantics(
            container: true,
            label: 'Mode Gelap',
            hint: _isDark ? 'Aktif' : 'Nonaktif. Ketuk untuk mengaktifkan',
            toggled: _isDark,
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  _iconBox(Icons.dark_mode_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mode Gelap',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tampilan latar gelap untuk kenyamanan mata',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isDark,
                    activeThumbColor: AppTheme.primary,
                    onChanged: _toggleDark,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          _sectionLabel('Ukuran Teks', textSecondary),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: surface,
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
              children: [
                for (int i = 0; i < FontScaleOption.values.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 56,
                      color: AppTheme.borderOf(context),
                    ),
                  _fontOptionTile(
                    FontScaleOption.values[i],
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          _sectionLabel('Pratinjau', textSecondary),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
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
              children: [
                Text(
                  'Selamat datang di Majadigi',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Layanan publik digital Provinsi Jawa Timur. Akses berbagai layanan pemerintahan dalam satu aplikasi.',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Pengaturan ini berlaku untuk seluruh aplikasi dan tersimpan otomatis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _fontOptionTile(
    FontScaleOption option, {
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final selected = _fontOption == option;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Ukuran teks ${option.label}',
      child: InkWell(
        onTap: () => _selectFont(option),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'A',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12 * option.scale,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primary,
                  size: 22,
                )
              else
                Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: textSecondary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppTheme.primary, size: 18),
    );
  }
}
