import 'package:intl/intl.dart';
import '../services/blockchain_service.dart';

enum UserRole { agriculteur, exportateur, verificateur, transformateur, cooperative }
extension UserRoleX on UserRole {
  String get label => const {
    UserRole.agriculteur:'Agriculteur', UserRole.exportateur:'Exportateur',
    UserRole.verificateur:'Vérificateur', UserRole.transformateur:'Transformateur',
    UserRole.cooperative:'Coopérative',
  }[this]!;
  String get icon => const {
    UserRole.agriculteur:'🌱', UserRole.exportateur:'🚢', UserRole.verificateur:'✅',
    UserRole.transformateur:'🏭', UserRole.cooperative:'🏛',
  }[this]!;
}

enum LotStatus { nouveau, enAttente, verifie, rejete, enTransformation, exporte }
extension LotStatusX on LotStatus {
  String get label => const {
    LotStatus.nouveau:'Nouveau', LotStatus.enAttente:'En attente',
    LotStatus.verifie:'Vérifié', LotStatus.rejete:'Rejeté',
    LotStatus.enTransformation:'En transformation', LotStatus.exporte:'Exporté',
  }[this]!;
}

class UserModel {
  String id, nom, prenom, email, telephone, region;
  UserRole role;
  String? photoUrl;
  PolygonWallet? wallet;
  UserModel({required this.id, required this.nom, required this.prenom,
    required this.email, required this.telephone,
    required this.region, required this.role, this.photoUrl}) {
    wallet = PolygonWallet(address: PolygonService.generateWalletAddress(), maticBalance: 2.45);
  }
  String get fullName => '$prenom $nom';
  String get initials => '${prenom.isNotEmpty?prenom[0]:''}${nom.isNotEmpty?nom[0]:''.toUpperCase()}'.toUpperCase();
}

class LotModel {
  final String id, lotId, culture, region, agriculteurNom;
  final double poids;
  final DateTime dateRecolte;
  LotStatus status;
  List<String> certifications;
  String? transformateurNom, exportateurNom;
  BlockchainRecord? blockchainRecord;
  bool get isOnBlockchain => blockchainRecord != null;
  LotModel({required this.id, required this.lotId, required this.culture,
    required this.poids, required this.region, required this.agriculteurNom,
    required this.dateRecolte, this.status = LotStatus.nouveau,
    this.certifications = const [], this.transformateurNom,
    this.exportateurNom, this.blockchainRecord});
}

class NotifModel {
  final String id, titre, message, type;
  final DateTime date;
  bool isRead;
  NotifModel({required this.id, required this.titre, required this.message,
    required this.type, required this.date, this.isRead = false});
}

class RegionStat { final String nom; final int lots; final double pct;
  RegionStat(this.nom, this.lots, this.pct); }

class AppState {
  static UserModel? user;
  static final List<LotModel> lots = [
    LotModel(id:'1', lotId:'LOT-TG-2026-1421', culture:'Cacao', poids:50,
      region:'Maritime', agriculteurNom:'Kofi Mensah',
      dateRecolte:DateTime(2026,3,30), status:LotStatus.verifie,
      certifications:['Bio','Fair Trade'],
      blockchainRecord: BlockchainRecord(lotId:'LOT-TG-2026-1421',
        txHash:'0x7d8f2a1b3c4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0',
        blockHash:'0x1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a',
        blockNumber:35482910, network:'Polygon Mumbai',
        contractAddress:'0x742d35Cc6634C0532925a3b844Bc9e7BcB4Oe9a5',
        timestamp:DateTime(2026,3,30,14,32,11), gasUsed:'21000', status:'confirmed',
        explorerUrl:'https://mumbai.polygonscan.com/tx/0x7d8f2a')),
    LotModel(id:'2', lotId:'LOT-TG-2026-3421', culture:'Cacao', poids:80,
      region:'Plateaux', agriculteurNom:'Ama Adjoa',
      dateRecolte:DateTime(2026,3,28), status:LotStatus.enAttente),
    LotModel(id:'3', lotId:'LOT-TG-2026-0413', culture:'Café', poids:120,
      region:'Centrale', agriculteurNom:'Yao Koffi',
      dateRecolte:DateTime(2026,3,25), status:LotStatus.enTransformation,
      certifications:['Fair Trade'], transformateurNom:'TransCacao SARL'),
    LotModel(id:'4', lotId:'LOT-TG-2026-9921', culture:'Cacao', poids:200,
      region:'Savanes', agriculteurNom:'Ablavi Sessou',
      dateRecolte:DateTime(2026,3,20), status:LotStatus.exporte,
      certifications:['Bio','Rainforest Alliance'], exportateurNom:'GreenExport SA'),
    LotModel(id:'5', lotId:'LOT-TG-2026-5512', culture:'Café', poids:45,
      region:'Kara', agriculteurNom:'Komlan Dossou',
      dateRecolte:DateTime(2026,4,1), status:LotStatus.nouveau),
  ];
  static final List<NotifModel> notifications = [
    NotifModel(id:'1',titre:'Lot vérifié ✅',message:'LOT-TG-2026-1421 validé avec succès.',type:'success',date:DateTime.now().subtract(const Duration(hours:2))),
    NotifModel(id:'2',titre:'Blockchain confirmé ⬡',message:'Transaction Polygon confirmée. Bloc #35482910.',type:'blockchain',date:DateTime.now().subtract(const Duration(hours:3))),
    NotifModel(id:'3',titre:'Paiement reçu 💰',message:'Paiement 500 XOF via T-Money. Réf: GS-2026-001.',type:'payment',date:DateTime.now().subtract(const Duration(hours:5))),
    NotifModel(id:'4',titre:'Certification obtenue 🏆',message:'Certification Bio attribuée.',type:'cert',date:DateTime.now().subtract(const Duration(days:1)),isRead:true),
    NotifModel(id:'5',titre:'Export confirmé 🚢',message:'LOT-TG-2026-9921 exporté.',type:'success',date:DateTime.now().subtract(const Duration(days:2)),isRead:true),
  ];
  static List<RegionStat> regions = [
    RegionStat('Plateaux',433,0.87), RegionStat('Maritime',313,0.63),
    RegionStat('Centrale',254,0.51), RegionStat('Kara',88,0.18), RegionStat('Savanes',47,0.09),
  ];
  static Map<String,int> dashboard = {'lots':1247,'exportateurs':806,'certifications':14,'zones':6,'agriculteurs':2356,'oja':44};
  static List<Map<String,dynamic>> production = [
    {'m':'Jan','v':120},{'m':'Fév','v':95},{'m':'Mar','v':140},
    {'m':'Avr','v':110},{'m':'Mai','v':160},{'m':'Juin','v':130},
  ];
  static int get unreadCount => notifications.where((n) => !n.isRead).length;
}
