import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import 'berita_data.dart';

class BeritaArsipPage extends StatefulWidget {
  const BeritaArsipPage({super.key});

  @override
  State<BeritaArsipPage> createState() => _BeritaArsipPageState();
}

class _BeritaArsipPageState extends State<BeritaArsipPage> {
  String _selectedTag = 'Semua';

  List<String> get _availableTags {
    final tags = {'Semua', for (final a in kBeritaArtikels) a.tag};
    return tags.toList();
  }

  List<ArtikelItem> get _filteredArtikels {
    if (_selectedTag == 'Semua') return kBeritaArtikels;
    return kBeritaArtikels.where((a) => a.tag == _selectedTag).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Arsip Berita & Artikel',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          const SizedBox(height: 4),
          Expanded(
            child: _filteredArtikels.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: _filteredArtikels.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _ArtikelCard(item: _filteredArtikels[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: AppTheme.surfaceOf(context),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _availableTags.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final tag = _availableTags[i];
            final selected = _selectedTag == tag;
            return GestureDetector(
              onTap: () => setState(() => _selectedTag = tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : AppTheme.backgroundOf(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.borderOf(context),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  tag,
                  style: TextStyle(
                    color: selected ? Colors.white : AppTheme.textSecondaryOf(context),
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ArtikelCard extends StatelessWidget {
  final ArtikelItem item;
  const _ArtikelCard({required this.item});

  Future<void> _open() async {
    final uri = Uri.parse(item.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Artikel ${item.tag}: ${item.title}, ${item.date}',
      hint: 'Buka artikel di browser',
      child: GestureDetector(
        onTap: _open,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                child: Image.asset(
                  item.assetPath,
                  width: 100,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 110,
                    color: const Color.fromRGBO(220, 232, 255, 1),
                    child: const Icon(Icons.article_rounded,
                        color: AppTheme.primary, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.tagColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textPrimaryOf(context),
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 10, color: AppTheme.textSecondaryOf(context)),
                          const SizedBox(width: 4),
                          Text(
                            item.date,
                            style: TextStyle(
                              color: AppTheme.textSecondaryOf(context),
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.open_in_new_rounded,
                              size: 12, color: AppTheme.textSecondaryOf(context)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined,
                size: 48, color: AppTheme.textSecondaryOf(context)),
            const SizedBox(height: 12),
            Text(
              'Belum ada artikel',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondaryOf(context),
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
