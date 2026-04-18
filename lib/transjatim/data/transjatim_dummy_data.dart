import 'package:flutter/material.dart';
import '../models/transjatim_model.dart';

class TransjatimDummyData {
  static final List<TicketCategory> ticketData = [
    TicketCategory('Umum', [
      TicketPrice('Umum', 'Rp2.500', '/tiket'),
      TicketPrice('Umum', 'Rp5.000', '/tiket'),
    ], Icons.payments),
    TicketCategory('Luxury', [
      TicketPrice('SBY - SDA Umum', 'Rp15.000', '/tiket'),
      TicketPrice('SBY - GSK Umum', 'Rp20.000', '/tiket'),
      TicketPrice('SDA - GSK Umum', 'Rp30.000', '/tiket'),
    ], Icons.payments),
  ];

  static final List<TransjatimRoute> routeData = [
    TransjatimRoute(
      id: 'JTM1',
      title: 'JTM1',
      operationalHours: '05:00 - 21:00',
      origin: 'Sidoarjo via Surabaya',
      destination: 'Gresik',
      stops: [
        'Halte Terminal Porong',
        'Halte Pondok Mutiara',
        'Halte Segoromadu I',
        'Terminal Bunder (OD)',
      ],
    ),
    TransjatimRoute(
      id: 'MLG1',
      title: 'MLG1',
      operationalHours: '05:00 - 21:00',
      origin: 'Terminal Hamid Rusdi',
      destination: 'Terminal Batu',
      stops: [
        'Terminal Hamid Rusdi',
        'Rambu Kawi 1',
        'Rambu Banjartengah 1',
        'Terminal Batu',
      ],
    ),
  ];
}
