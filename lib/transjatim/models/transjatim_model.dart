import 'package:flutter/material.dart';

class TicketCategory {
  final String title;
  final List<TicketPrice> prices;
  final IconData icon;

  TicketCategory(this.title, this.prices, this.icon);
}

class TicketPrice {
  final String category;
  final String price;
  final String suffix;

  TicketPrice(this.category, this.price, this.suffix);
}

class TransjatimRoute {
  final String id;
  final String title;
  final String operationalHours;
  final String origin;
  final String destination;
  final List<String> stops;

  TransjatimRoute({
    required this.id,
    required this.title,
    required this.operationalHours,
    required this.origin,
    required this.destination,
    required this.stops,
  });
}
