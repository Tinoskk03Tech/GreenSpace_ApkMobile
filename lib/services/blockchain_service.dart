import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

// ── Polygon Blockchain Service ─────────────────────────────────────────────
// Intégration avec Polygon Mumbai Testnet (puis Mainnet en production)
class PolygonService {
  static const String _rpcUrl    = 'https://rpc-mumbai.maticvigil.com';
  static const String _apiKey    = 'YOUR_POLYGON_API_KEY'; // À configurer
  static const String _chainId   = '80001'; // Mumbai testnet
  static const String _explorerUrl = 'https://mumbai.polygonscan.com';

  // ── Générer un hash de traçabilité pour un lot ─────────────────────────
  static String generateLotHash(Map<String, dynamic> lotData) {
    final content = json.encode({
      'lotId':          lotData['lotId'],
      'agriculteur':    lotData['agriculteur'],
      'culture':        lotData['culture'],
      'poids':          lotData['poids'],
      'region':         lotData['region'],
      'dateRecolte':    lotData['dateRecolte'],
      'certifications': lotData['certifications'],
      'timestamp':      DateTime.now().toIso8601String(),
    });
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return '0x${digest.toString()}';
  }

  // ── Générer une adresse wallet Polygon simulée ────────────────────────
  static String generateWalletAddress() {
    final rng = Random.secure();
    final bytes = List<int>.generate(20, (_) => rng.nextInt(256));
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  // ── Générer un transaction hash ───────────────────────────────────────
  static String generateTxHash() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  // ── Simuler l'enregistrement sur blockchain ───────────────────────────
  static Future<BlockchainRecord> registerLot({
    required String lotId,
    required String agriculteur,
    required String culture,
    required double poids,
    required String region,
    required DateTime dateRecolte,
    required List<String> certifications,
  }) async {
    // Simulation d'un appel RPC Polygon
    await Future.delayed(const Duration(milliseconds: 1800));

    final hash = generateLotHash({
      'lotId': lotId, 'agriculteur': agriculteur, 'culture': culture,
      'poids': poids, 'region': region,
      'dateRecolte': dateRecolte.toIso8601String(),
      'certifications': certifications,
    });

    final txHash = generateTxHash();
    final blockNumber = 35000000 + Random().nextInt(1000000);

    return BlockchainRecord(
      lotId: lotId,
      txHash: txHash,
      blockHash: hash,
      blockNumber: blockNumber,
      network: 'Polygon Mumbai',
      contractAddress: '0x742d35Cc6634C0532925a3b844Bc9e7BcB4Oe9a5',
      timestamp: DateTime.now(),
      gasUsed: '21000',
      status: 'confirmed',
      explorerUrl: '$_explorerUrl/tx/$txHash',
    );
  }

  // ── Vérifier un hash sur la blockchain ───────────────────────────────
  static Future<VerificationResult> verifyHash(String hash) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simulation de vérification
    final isValid = hash.startsWith('0x') && hash.length >= 10;
    return VerificationResult(
      isValid: isValid,
      hash: hash,
      verifiedAt: DateTime.now(),
      network: 'Polygon Mumbai',
      confidence: isValid ? 99.9 : 0.0,
    );
  }

  // ── Obtenir le solde MATIC d'un wallet ────────────────────────────────
  static Future<double> getMaticBalance(String walletAddress) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 2.45 + Random().nextDouble() * 10;
  }

  // ── Lien explorateur ──────────────────────────────────────────────────
  static String getExplorerLink(String txHash) =>
      '$_explorerUrl/tx/$txHash';

  static String getAddressExplorerLink(String address) =>
      '$_explorerUrl/address/$address';
}

// ── Modèles Blockchain ─────────────────────────────────────────────────────
class BlockchainRecord {
  final String lotId, txHash, blockHash, network, contractAddress, gasUsed, status, explorerUrl;
  final int blockNumber;
  final DateTime timestamp;

  BlockchainRecord({
    required this.lotId, required this.txHash, required this.blockHash,
    required this.blockNumber, required this.network, required this.contractAddress,
    required this.timestamp, required this.gasUsed, required this.status,
    required this.explorerUrl,
  });

  Map<String, dynamic> toJson() => {
    'lotId': lotId, 'txHash': txHash, 'blockHash': blockHash,
    'blockNumber': blockNumber, 'network': network,
    'contractAddress': contractAddress, 'timestamp': timestamp.toIso8601String(),
    'gasUsed': gasUsed, 'status': status,
  };
}

class VerificationResult {
  final bool isValid;
  final String hash, network;
  final DateTime verifiedAt;
  final double confidence;

  VerificationResult({
    required this.isValid, required this.hash, required this.network,
    required this.verifiedAt, required this.confidence,
  });
}

// ── Wallet Model ───────────────────────────────────────────────────────────
class PolygonWallet {
  final String address;
  double maticBalance;
  final List<BlockchainRecord> transactions;

  PolygonWallet({
    required this.address,
    this.maticBalance = 0.0,
    List<BlockchainRecord>? transactions,
  }) : transactions = transactions ?? [];

  String get shortAddress =>
      '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
}
