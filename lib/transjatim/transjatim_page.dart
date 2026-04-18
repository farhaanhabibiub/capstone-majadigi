import 'package:flutter/material.dart';
import 'data/transjatim_dummy_data.dart';
import 'models/transjatim_model.dart';
import 'widgets/route_card.dart';
import 'widgets/halte_map_widget.dart';
import 'pages/buy_ticket_page.dart';

class TransjatimPage extends StatefulWidget {
  const TransjatimPage({Key? key}) : super(key: key);

  @override
  State<TransjatimPage> createState() => _TransjatimPageState();
}

class _TransjatimPageState extends State<TransjatimPage> {
  static const Color _blue = Color.fromRGBO(0, 101, 255, 1);
  static const Color _whiteBg = Color.fromRGBO(248, 248, 245, 1);
  static const Color _textPrimary = Color.fromRGBO(32, 32, 32, 1);
  static const Color _textSecondary = Color.fromRGBO(120, 120, 120, 1);

  int _selectedTabIndex = 0;

  static const List<String> _tabs = ['Beli Tiket', 'Rute', 'Peta'];

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = kToolbarHeight + statusBarHeight + 36;

    return Scaffold(
      backgroundColor: _blue,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Transjatim',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.bookmark_outline_rounded, color: _blue, size: 20),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: headerHeight + 50,
            child: Container(
              decoration: const BoxDecoration(color: _blue),
            ),
          ),
          Column(
            children: [
              SizedBox(height: headerHeight),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _whiteBg,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildTabSwitcher(),
                      const SizedBox(height: 16),
                      Expanded(child: _buildCurrentTab()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final isSelected = _selectedTabIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = i),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? _blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      color: isSelected ? Colors.white : _textPrimary,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildBeliTiketView();
      case 1:
        return _buildRuteView();
      case 2:
        return const HalteMapWidget();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBeliTiketView() {
    final routes = TransjatimDummyData.routes;
    final cities = <String>[];
    for (final r in routes) {
      if (!cities.contains(r.city)) cities.add(r.city);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        ...cities.expand((city) {
          final cityRoutes = routes.where((r) => r.city == city).toList();
          return [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              child: Text(city, style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            ...cityRoutes.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBuyCard(r),
            )),
          ];
        }),
      ],
    );
  }

  Widget _buildBuyCard(TransjatimRoute route) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(20)),
                child: Text(route.id, style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              if (route.hasLuxury)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 248, 230, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.star_rounded, size: 11, color: Color.fromRGBO(217, 119, 6, 1)),
                      SizedBox(width: 3),
                      Text('Luxury', style: TextStyle(color: Color.fromRGBO(217, 119, 6, 1), fontFamily: 'PlusJakartaSans', fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              const Spacer(),
              const Icon(Icons.access_time_rounded, size: 12, color: _textSecondary),
              const SizedBox(width: 4),
              Text(route.operationalHours, style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text(route.title, style: const TextStyle(color: _textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            '${route.stops.length} halte  •  Ekonomi mulai Rp 2.500',
            style: const TextStyle(color: _textSecondary, fontFamily: 'PlusJakartaSans', fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BuyTicketPage(route: route)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text(
                'Beli Tiket',
                style: TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuteView() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: TransjatimDummyData.routes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => RouteCard(route: TransjatimDummyData.routes[i]),
    );
  }
}
