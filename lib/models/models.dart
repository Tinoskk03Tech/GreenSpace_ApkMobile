enum UserRole { agriculteur, exportateur, verificateur, transformateur, cooperative }

extension UserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.agriculteur: return 'Agriculteur';
      case UserRole.exportateur: return 'Exportateur';
      case UserRole.verificateur: return 'Vérificateur';
      case UserRole.transformateur: return 'Transformateur';
      case UserRole.cooperative: return 'Coopérative';
    }
  }

  String get icon {
    switch (this) {
      case UserRole.agriculteur: return '🌱';
      case UserRole.exportateur: return '🚢';
      case UserRole.verificateur: return '✅';
      case UserRole.transformateur: return '🏭';
      case UserRole.cooperative: return '🏛';
    }
  }
}

enum LotStatus { nouveau, enAttente, verifie, rejete, enTransformation, exporte }

extension LotStatusExt on LotStatus {
  String get label {
    switch (this) {
      case LotStatus.nouveau: return 'Nouveau';
      case LotStatus.enAttente: return 'En attente';
      case LotStatus.verifie: return 'Vérifié';
      case LotStatus.rejete: return 'Rejeté';
      case LotStatus.enTransformation: return 'En transformation';
      case LotStatus.exporte: return 'Exporté';
    }
  }
}

class UserModel {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final UserRole role;
  final String region;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    required this.region,
  });
}

class LotModel {
  final String id;
  final String lotId;
  final String culture; // Cacao, Café
  final double poids;
  final String region;
  final String agriculteurNom;
  final DateTime dateRecolte;
  LotStatus status;
  final List<String> certifications;
  final String? qrData;
  String? transformateurNom;
  String? exportateurNom;

  LotModel({
    required this.id,
    required this.lotId,
    required this.culture,
    required this.poids,
    required this.region,
    required this.agriculteurNom,
    required this.dateRecolte,
    this.status = LotStatus.nouveau,
    this.certifications = const [],
    this.qrData,
    this.transformateurNom,
    this.exportateurNom,
  });
}

class RegionStats {
  final String nom;
  final int lots;
  final int agriculteurs;

  RegionStats({required this.nom, required this.lots, required this.agriculteurs});
}

class AppData {
  static UserModel? currentUser;

  static final List<LotModel> lots = [
    LotModel(
      id: '1',
      lotId: 'LOT-TG-2026-1421',
      culture: 'Cacao',
      poids: 50,
      region: 'Maritime',
      agriculteurNom: 'Kofi Mensah',
      dateRecolte: DateTime(2026, 3, 30),
      status: LotStatus.verifie,
      certifications: ['Bio', 'Fair Trade'],
      qrData: 'LOT-TG-2026-1421|Cacao|50kg|Maritime|Kofi Mensah',
    ),
    LotModel(
      id: '2',
      lotId: 'LOT-TG-2026-3421',
      culture: 'Cacao',
      poids: 80,
      region: 'Plateaux',
      agriculteurNom: 'Ama Adjoa',
      dateRecolte: DateTime(2026, 3, 28),
      status: LotStatus.enAttente,
      certifications: [],
      qrData: 'LOT-TG-2026-3421|Cacao|80kg|Plateaux|Ama Adjoa',
    ),
    LotModel(
      id: '3',
      lotId: 'LOT-TG-2026-0413',
      culture: 'Café',
      poids: 120,
      region: 'Centrale',
      agriculteurNom: 'Yao Koffi',
      dateRecolte: DateTime(2026, 3, 25),
      status: LotStatus.enTransformation,
      certifications: ['Fair Trade'],
      qrData: 'LOT-TG-2026-0413|Café|120kg|Centrale|Yao Koffi',
      transformateurNom: 'TransCacao SARL',
    ),
    LotModel(
      id: '4',
      lotId: 'LOT-TG-2026-9921',
      culture: 'Cacao',
      poids: 200,
      region: 'Savanes',
      agriculteurNom: 'Ablavi Sessou',
      dateRecolte: DateTime(2026, 3, 20),
      status: LotStatus.exporte,
      certifications: ['Bio', 'Rainforest Alliance'],
      qrData: 'LOT-TG-2026-9921|Cacao|200kg|Savanes|Ablavi Sessou',
      exportateurNom: 'GreenExport SA',
    ),
    LotModel(
      id: '5',
      lotId: 'LOT-TG-2026-5512',
      culture: 'Café',
      poids: 45,
      region: 'Kara',
      agriculteurNom: 'Komlan Dossou',
      dateRecolte: DateTime(2026, 4, 1),
      status: LotStatus.nouveau,
      certifications: [],
      qrData: 'LOT-TG-2026-5512|Café|45kg|Kara|Komlan Dossou',
    ),
  ];

  static List<RegionStats> regions = [
    RegionStats(nom: 'Plateaux', lots: 433, agriculteurs: 189),
    RegionStats(nom: 'Maritime', lots: 313, agriculteurs: 142),
    RegionStats(nom: 'Centrale', lots: 254, agriculteurs: 98),
    RegionStats(nom: 'Kara', lots: 88, agriculteurs: 41),
    RegionStats(nom: 'Savanes', lots: 47, agriculteurs: 22),
  ];

  static Map<String, int> dashboardStats = {
    'lots': 1247,
    'exportateurs': 806,
    'certifications': 14,
    'zones': 6,
    'agriculteurs': 2356,
    'oja': 44,
  };

  static List<Map<String, dynamic>> productionMensuelle = [
    {'mois': 'Jan', 'tonnes': 120},
    {'mois': 'Fév', 'tonnes': 95},
    {'mois': 'Mar', 'tonnes': 140},
    {'mois': 'Avr', 'tonnes': 110},
    {'mois': 'Mai', 'tonnes': 160},
    {'mois': 'Juin', 'tonnes': 130},
  ];

  static Map<String, int> certificationRepartition = {
    'Bio': 320,
    'Fair Trade': 380,
    'Non cert.': 226,
  };
}
