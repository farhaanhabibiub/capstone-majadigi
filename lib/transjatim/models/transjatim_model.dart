import 'dart:convert';

enum TicketClass { economy, luxury }

extension TicketClassLabel on TicketClass {
  String get label => this == TicketClass.economy ? 'Ekonomi' : 'Luxury';
}

class TransjatimStop {
  final String name;
  final double lat;
  final double lng;

  const TransjatimStop({
    required this.name,
    required this.lat,
    required this.lng,
  });
}

class TransjatimRoute {
  final String id;
  final String title;
  final String city;
  final String operationalHours;
  final List<TransjatimStop> stops;
  final bool hasLuxury;
  final int luxuryPriceFlat;

  const TransjatimRoute({
    required this.id,
    required this.title,
    required this.city,
    required this.operationalHours,
    required this.stops,
    this.hasLuxury = false,
    this.luxuryPriceFlat = 0,
  });

  String get origin => stops.first.name;
  String get destination => stops.last.name;

  /// Ekonomi: Rp 2.500/segmen, maks Rp 5.000.
  /// Luxury: flat [luxuryPriceFlat].
  int calculatePrice(int fromIndex, int toIndex, TicketClass ticketClass) {
    if (ticketClass == TicketClass.luxury) return luxuryPriceFlat;
    final segments = toIndex - fromIndex;
    return (segments * 2500).clamp(0, 5000);
  }
}

class TicketOrder {
  final String orderId;
  final TransjatimRoute route;
  final int fromIndex;
  final int toIndex;
  final TicketClass ticketClass;
  final int passengerCount;
  final String paymentMethod;
  final DateTime bookingTime;

  const TicketOrder({
    required this.orderId,
    required this.route,
    required this.fromIndex,
    required this.toIndex,
    required this.ticketClass,
    required this.passengerCount,
    required this.paymentMethod,
    required this.bookingTime,
  });

  int get pricePerPax => route.calculatePrice(fromIndex, toIndex, ticketClass);
  int get totalPrice => pricePerPax * passengerCount;
  String get fromStop => route.stops[fromIndex].name;
  String get toStop => route.stops[toIndex].name;

  String get qrData => jsonEncode({
        'id': orderId,
        'route': '${route.id} - ${route.title}',
        'from': fromStop,
        'to': toStop,
        'class': ticketClass.label,
        'passengers': passengerCount,
        'total': totalPrice,
        'payment': paymentMethod,
        'booked_at': bookingTime.toIso8601String(),
      });
}
