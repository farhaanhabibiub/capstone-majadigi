import 'package:flutter/material.dart';
import '../app_route.dart';
import '../rsud/hospital_config.dart';

class AddableService {
  final String id;
  final String label;
  final String assetPath;
  final IconData fallback;
  final String? route;
  final HospitalConfig? hospital;

  const AddableService({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.fallback,
    this.route,
    this.hospital,
  });
}

class ServiceRegistry {
  static const List<AddableService> all = [
    AddableService(
      id: 'sapa_bansos',
      label: 'SAPA BANSOS',
      assetPath: 'assets/images/layanan_sapa_bansos.png',
      fallback: Icons.volunteer_activism_rounded,
      route: AppRoutes.sapaBansosPage,
    ),
    AddableService(
      id: 'etibi',
      label: 'E-TIBI',
      assetPath: 'assets/images/layanan_etibi.png',
      fallback: Icons.medical_services_rounded,
      route: AppRoutes.etibiPage,
    ),
    AddableService(
      id: 'klinik_hoaks',
      label: 'Klinik Hoaks',
      assetPath: 'assets/images/layanan_klinik_hoaks.png',
      fallback: Icons.fact_check_rounded,
      route: AppRoutes.klinikHoaksLandingPage,
    ),
    AddableService(
      id: 'open_data',
      label: 'Open Data',
      assetPath: 'assets/images/layanan_open_data.png',
      fallback: Icons.dataset_rounded,
      route: AppRoutes.openDataLandingPage,
    ),
    AddableService(
      id: 'rsud_daha_husada',
      label: 'RSUD Daha Husada',
      assetPath: 'assets/images/layanan_rsud.png',
      fallback: Icons.local_hospital_rounded,
      hospital: HospitalConfig.dahaHusada,
    ),
    AddableService(
      id: 'rsud_karsa_husada',
      label: 'RSUD Karsa Husada',
      assetPath: 'assets/images/layanan_rsud.png',
      fallback: Icons.local_hospital_rounded,
      hospital: HospitalConfig.karsaHusada,
    ),
    AddableService(
      id: 'rsud_saiful_anwar',
      label: 'RSUD Saiful Anwar',
      assetPath: 'assets/images/layanan_rsud.png',
      fallback: Icons.local_hospital_rounded,
      hospital: HospitalConfig.saifulAnwar,
    ),
    AddableService(
      id: 'rsud_prov_jatim',
      label: 'RSUD Prov. Jatim',
      assetPath: 'assets/images/layanan_rsud.png',
      fallback: Icons.local_hospital_rounded,
      hospital: HospitalConfig.provJatim,
    ),
  ];

  static AddableService? findById(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Metadata untuk semua featureId yang dicatat oleh FeatureUsageService —
  /// termasuk layanan unggulan di beranda yang tidak ada di [all].
  ///
  /// Dipakai oleh halaman Profil untuk merender Aktivitas Terakhir & Statistik.
  static FeatureMeta? metaFor(String id) {
    final addable = findById(id);
    if (addable != null) {
      return FeatureMeta(
        id: addable.id,
        label: addable.label,
        icon: addable.fallback,
        route: addable.route,
        hospital: addable.hospital,
      );
    }
    return _coreMeta[id];
  }

  static const Map<String, FeatureMeta> _coreMeta = {
    'bapenda': FeatureMeta(
      id: 'bapenda',
      label: 'BAPENDA',
      icon: Icons.account_balance_rounded,
      route: AppRoutes.bapendaPage,
    ),
    'rsud': FeatureMeta(
      id: 'rsud',
      label: 'RSUD',
      icon: Icons.local_hospital_rounded,
    ),
    'transjatim': FeatureMeta(
      id: 'transjatim',
      label: 'Transjatim',
      icon: Icons.directions_bus_rounded,
      route: AppRoutes.transjatimPage,
    ),
    'siskaperbapo': FeatureMeta(
      id: 'siskaperbapo',
      label: 'SISKAPERBAPO',
      icon: Icons.storefront_rounded,
      route: AppRoutes.siskaperbapoPage,
    ),
    'nomor_darurat': FeatureMeta(
      id: 'nomor_darurat',
      label: 'Nomor Darurat',
      icon: Icons.emergency_rounded,
      route: AppRoutes.nomorDaruratLandingPage,
    ),
  };
}

class FeatureMeta {
  final String id;
  final String label;
  final IconData icon;
  final String? route;
  final HospitalConfig? hospital;

  const FeatureMeta({
    required this.id,
    required this.label,
    required this.icon,
    this.route,
    this.hospital,
  });
}
