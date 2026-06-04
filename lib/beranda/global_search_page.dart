import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_transitions.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'feature_usage_service.dart';
import 'search_index.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  static const _recentKey = 'global_search_recent';
  static const _maxRecent = 6;
  static const _itemsPerSection = 5;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  String _query = '';
  List<String> _recent = [];
  final Set<SearchCategory> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _loadRecent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_recentKey) ?? const [];
    if (!mounted) return;
    setState(() => _recent = list);
  }

  Future<void> _saveRecent(String term) async {
    final clean = term.trim();
    if (clean.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(_recent);
    list.removeWhere((e) => e.toLowerCase() == clean.toLowerCase());
    list.insert(0, clean);
    while (list.length > _maxRecent) {
      list.removeLast();
    }
    await prefs.setStringList(_recentKey, list);
    if (mounted) setState(() => _recent = list);
  }

  Future<void> _clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
    if (mounted) setState(() => _recent = []);
  }

  void _onItemTap(SearchableItem item) {
    _saveRecent(item.title);
    if (item.route == null) return;
    FeatureUsageService.recordOpen(_trackId(item));
    Navigator.pushNamed(context, item.route!, arguments: item.routeArguments);
  }

  /// Catat semua RSUD sebagai 'rsud' agar saran AI tetap menyatu.
  String _trackId(SearchableItem item) =>
      item.category == SearchCategory.rsud ? 'rsud' : item.id;

  @override
  Widget build(BuildContext context) {
    final results = SearchIndex.search(_query);

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _query.isEmpty
                  ? _buildIdleState()
                  : results.isEmpty
                      ? _buildNoResults()
                      : _buildResults(results),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Search Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: AppTheme.textPrimaryOf(context)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                onChanged: (v) => setState(() {
                  _query = v;
                  _expandedSections.clear();
                }),
                onSubmitted: _saveRecent,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  color: AppTheme.textPrimaryOf(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Cari layanan, RSUD, hoaks, data…',
                  hintStyle: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppTheme.textSecondaryOf(context),
                    size: 20,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          splashRadius: 18,
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppTheme.textSecondaryOf(context),
                            size: 18,
                          ),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              _query = '';
                              _expandedSections.clear();
                            });
                          },
                        ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Idle (no query) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildIdleState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        if (_recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pencarian Terakhir',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _clearRecent,
                child: const Text(
                  'Hapus',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recent.map((term) {
              return GestureDetector(
                onTap: () {
                  _controller.text = term;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: term.length),
                  );
                  setState(() {
                    _query = term;
                    _expandedSections.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceOf(context),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: const Color.fromRGBO(225, 230, 240, 1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded,
                          size: 14, color: AppTheme.textSecondaryOf(context)),
                      const SizedBox(width: 6),
                      Text(
                        term,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: AppTheme.textPrimaryOf(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
        ],
        Text(
          'Saran Populer',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions.map((s) {
            return GestureDetector(
              onTap: () {
                _controller.text = s;
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: s.length),
                );
                setState(() {
                  _query = s;
                  _expandedSections.clear();
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(235, 243, 255, 1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        Text(
          'Jelajahi Kategori',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        const SizedBox(height: 10),
        ..._buildBrowseSections(),
      ],
    );
  }

  static const List<String> _suggestions = [
    'Pajak kendaraan',
    'RSUD Malang',
    'Hoaks',
    'Bansos',
    'Tiket Trans Jatim',
    'Harga sembako',
    'Nomor darurat',
  ];

  List<Widget> _buildBrowseSections() {
    final byCategory = <SearchCategory, List<SearchableItem>>{};
    for (final item in SearchIndex.all) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    final widgets = <Widget>[];
    for (final cat in SearchCategory.values) {
      final items = byCategory[cat];
      if (items == null || items.isEmpty) continue;
      widgets.add(_buildSection(cat, items));
      widgets.add(const SizedBox(height: 14));
    }
    return widgets;
  }

  Widget _buildSection(SearchCategory cat, List<SearchableItem> items) {
    final isExpanded = _expandedSections.contains(cat);
    final hasMore = items.length > _itemsPerSection;
    final visible =
        (isExpanded || !hasMore) ? items : items.sublist(0, _itemsPerSection);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                Icon(cat.icon, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryOf(context),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Text(
                  '${items.length}',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          ...visible.map(_buildResultTile),
          if (hasMore) _buildExpandToggle(cat, items.length, isExpanded),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildExpandToggle(SearchCategory cat, int total, bool isExpanded) {
    final remaining = total - _itemsPerSection;
    final label = isExpanded
        ? 'Tampilkan lebih sedikit'
        : 'Lihat semua ($remaining lainnya)';
    return InkWell(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedSections.remove(cat);
          } else {
            _expandedSections.add(cat);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              isExpanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              size: 18,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Results â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildResults(List<SearchableItem> results) {
    final byCategory = <SearchCategory, List<SearchableItem>>{};
    for (final item in results) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4),
          child: Text(
            '${results.length} hasil untuk "$_query"',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
        ),
        for (final cat in SearchCategory.values)
          if (byCategory[cat] != null) ...[
            _buildSection(cat, byCategory[cat]!),
            const SizedBox(height: 14),
          ],
      ],
    );
  }

  Widget _buildResultTile(SearchableItem item) {
    return InkWell(
      onTap: () => _onItemTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Hero(
              tag: HeroTags.serviceCard(item.id),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(235, 243, 255, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: AppTheme.primary, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondaryOf(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'Tidak ditemukan',
      subtitle: 'Coba kata kunci lain seperti "pajak", "RSUD", atau "bansos".',
      actionLabel: 'Hapus pencarian',
      onAction: () {
        _controller.clear();
        setState(() {
          _query = '';
          _expandedSections.clear();
        });
      },
    );
  }
}
