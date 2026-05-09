import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'blockchain_service.dart';

// ── QR Code Data Generator ─────────────────────────────────────────────────
class QrCodeService {
  // Générer les données JSON complètes pour le QR Code EJOK
  static String generateEjokQrData({
    required LotModel lot,
    BlockchainRecord? blockchain,
    String? exportateur,
  }) {
    final data = {
      'type':           'EJOK_GREENSPACE_V1',
      'lotId':          lot.lotId,
      'culture':        lot.culture,
      'poids':          '${lot.poids.toInt()} kg',
      'region':         lot.region,
      'agriculteur':    lot.agriculteurNom,
      'dateRecolte':    DateFormat('dd/MM/yyyy').format(lot.dateRecolte),
      'statut':         lot.status.label,
      'certifications': lot.certifications,
      'exportateur':    exportateur ?? lot.exportateurNom ?? 'N/A',
      'blockchain': blockchain != null ? {
        'txHash':        blockchain.txHash,
        'network':       blockchain.network,
        'blockNumber':   blockchain.blockNumber,
        'timestamp':     blockchain.timestamp.toIso8601String(),
      } : null,
      'generatedAt':    DateTime.now().toIso8601String(),
      'verifyUrl':      'https://greenspace.tg/verify/${lot.lotId}',
    };

    return json.encode(data);
  }

  // Hash de vérification court
  static String generateVerifyHash(String lotId) {
    final bytes = utf8.encode('EJOK-$lotId-${DateTime.now().year}');
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16).toUpperCase();
  }
}

// ── PDF Document Generator ─────────────────────────────────────────────────
class PdfService {
  static final _green     = PdfColor.fromHex('#2E7D32');
  static final _greenDark = PdfColor.fromHex('#1B5E20');
  static final _brown     = PdfColor.fromHex('#6D4C1F');
  static final _greenPale = PdfColor.fromHex('#E8F5E9');
  static final _polygon   = PdfColor.fromHex('#8247E5');
  static final _white     = PdfColors.white;
  static final _grey      = PdfColor.fromHex('#546E7A');

  // ── Certificat d'Export EJOK ───────────────────────────────────────────
  static Future<Uint8List> generateExportCertificate({
    required LotModel lot,
    required String exportateur,
    BlockchainRecord? blockchain,
    String? qrImageBase64,
  }) async {
    final pdf = pw.Document(
      title: 'Certificat Export EJOK - ${lot.lotId}',
      author: 'GreenSpace Togo',
    );

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: _green,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('GREENSPACE',
                      style: pw.TextStyle(color: _white, fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Traçabilité Agricole — Togo',
                      style: pw.TextStyle(color: PdfColor.fromHex('#C8E6C9'), fontSize: 11)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('CERTIFICAT D\'EXPORT EJOK',
                      style: pw.TextStyle(color: _white, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                      style: pw.TextStyle(color: PdfColor.fromHex('#A5D6A7'), fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Identifiant lot ────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: _greenPale,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _green, width: 1),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Numéro de Lot', style: pw.TextStyle(color: _grey, fontSize: 9)),
                  pw.Text(lot.lotId, style: pw.TextStyle(color: _greenDark, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ]),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: _green,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text('EXPORTÉ ✓',
                    style: pw.TextStyle(color: _white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ── Détails du lot ─────────────────────────────────────────────
          pw.Text('DÉTAILS DU LOT',
            style: pw.TextStyle(color: _greenDark, fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromHex('#C8E6C9'), width: 0.5),
            children: [
              _tableRow('Culture', lot.culture, 'Poids', '${lot.poids.toInt()} kg'),
              _tableRow('Région', lot.region, 'Agriculteur', lot.agriculteurNom),
              _tableRow('Date récolte', DateFormat('dd/MM/yyyy').format(lot.dateRecolte),
                'Exportateur', exportateur),
              _tableRow('Certifications', lot.certifications.isEmpty ? 'Aucune' : lot.certifications.join(', '),
                'Statut', lot.status.label),
            ],
          ),
          pw.SizedBox(height: 16),

          // ── Certifications ─────────────────────────────────────────────
          if (lot.certifications.isNotEmpty) ...[
            pw.Text('CERTIFICATIONS OBTENUES',
              style: pw.TextStyle(color: _greenDark, fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Wrap(
              spacing: 8, runSpacing: 6,
              children: lot.certifications.map((c) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _greenPale,
                  borderRadius: pw.BorderRadius.circular(20),
                  border: pw.Border.all(color: _green, width: 0.8),
                ),
                child: pw.Text('✓ $c',
                  style: pw.TextStyle(color: _green, fontSize: 9, fontWeight: pw.FontWeight.bold)),
              )).toList(),
            ),
            pw.SizedBox(height: 16),
          ],

          // ── Blockchain Polygon ─────────────────────────────────────────
          if (blockchain != null) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F3EEFE'),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: _polygon, width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(children: [
                    pw.Text('⬡ ', style: pw.TextStyle(color: _polygon, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.Text('ENREGISTRÉ SUR BLOCKCHAIN POLYGON',
                      style: pw.TextStyle(color: _polygon, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ]),
                  pw.SizedBox(height: 8),
                  _blockchainRow('Réseau', blockchain.network),
                  _blockchainRow('Transaction', _shortHash(blockchain.txHash)),
                  _blockchainRow('Hash du bloc', _shortHash(blockchain.blockHash)),
                  _blockchainRow('Numéro de bloc', '${blockchain.blockNumber}'),
                  _blockchainRow('Horodatage', DateFormat('dd/MM/yyyy HH:mm:ss').format(blockchain.timestamp)),
                  _blockchainRow('Contrat', _shortHash(blockchain.contractAddress)),
                  _blockchainRow('Gaz utilisé', '${blockchain.gasUsed} Gwei'),
                  _blockchainRow('Statut', blockchain.status.toUpperCase()),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // ── Footer ─────────────────────────────────────────────────────
          pw.Divider(color: PdfColor.fromHex('#C8E6C9')),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('GreenSpace · Ministère de l\'Agriculture Togo',
                  style: pw.TextStyle(color: _grey, fontSize: 8)),
                pw.Text('Ce certificat est vérifiable sur greenspace.tg',
                  style: pw.TextStyle(color: _grey, fontSize: 7)),
              ]),
              pw.Text('Page 1/1',
                style: pw.TextStyle(color: _grey, fontSize: 8)),
            ],
          ),
        ],
      ),
    ));

    return pdf.save();
  }

  // ── Rapport de Lot complet ─────────────────────────────────────────────
  static Future<Uint8List> generateLotReport({
    required LotModel lot,
    BlockchainRecord? blockchain,
  }) async {
    final pdf = pw.Document(title: 'Rapport Lot ${lot.lotId}');

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      header: (ctx) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _green, width: 2)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('GREENSPACE', style: pw.TextStyle(color: _green, fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('Rapport de Lot — ${lot.lotId}',
              style: pw.TextStyle(color: _grey, fontSize: 10)),
          ],
        ),
      ),
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('GreenSpace Togo © ${DateTime.now().year}',
            style: pw.TextStyle(color: _grey, fontSize: 8)),
          pw.Text('Page ${ctx.pageNumber} / ${ctx.pagesCount}',
            style: pw.TextStyle(color: _grey, fontSize: 8)),
        ],
      ),
      build: (ctx) => [
        pw.SizedBox(height: 12),
        pw.Text('RAPPORT DE TRAÇABILITÉ',
          style: pw.TextStyle(color: _greenDark, fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Généré le ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: pw.TextStyle(color: _grey, fontSize: 10)),
        pw.SizedBox(height: 20),

        // Infos lot
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(color: _greenPale, borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Column(children: [
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text(lot.lotId, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _greenDark)),
              pw.Text(lot.status.label, style: pw.TextStyle(fontSize: 10, color: _green, fontWeight: pw.FontWeight.bold)),
            ]),
          ]),
        ),
        pw.SizedBox(height: 12),

        _sectionTitle('Informations du lot'),
        _infoTable([
          ['Culture', lot.culture],
          ['Poids', '${lot.poids.toInt()} kg'],
          ['Région', lot.region],
          ['Agriculteur', lot.agriculteurNom],
          ['Date récolte', DateFormat('dd/MM/yyyy').format(lot.dateRecolte)],
          ['Certifications', lot.certifications.isEmpty ? 'Aucune' : lot.certifications.join(', ')],
          if (lot.transformateurNom != null) ['Transformateur', lot.transformateurNom!],
          if (lot.exportateurNom != null) ['Exportateur', lot.exportateurNom!],
        ]),
        pw.SizedBox(height: 16),

        if (blockchain != null) ...[
          _sectionTitle('Enregistrement Blockchain Polygon'),
          _infoTable([
            ['Réseau', blockchain.network],
            ['Hash transaction', _shortHash(blockchain.txHash)],
            ['Numéro de bloc', '${blockchain.blockNumber}'],
            ['Contrat', _shortHash(blockchain.contractAddress)],
            ['Gaz utilisé', '${blockchain.gasUsed} Gwei'],
            ['Statut', blockchain.status],
            ['Horodatage', DateFormat('dd/MM/yyyy HH:mm:ss').format(blockchain.timestamp)],
          ]),
          pw.SizedBox(height: 8),
          pw.Text('Vérifier sur: ${blockchain.explorerUrl}',
            style: pw.TextStyle(color: _polygon, fontSize: 8)),
        ],
      ],
    ));

    return pdf.save();
  }

  // ── Reçu de paiement ──────────────────────────────────────────────────
  static Future<Uint8List> generatePaymentReceipt({
    required String reference,
    required String method,
    required double amount,
    required String currency,
    required String description,
    required DateTime date,
    String? lotId,
    String? receiptNumber,
  }) async {
    final pdf = pw.Document(title: 'Reçu $reference');

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(color: _green, borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Column(children: [
              pw.Text('GREENSPACE', style: pw.TextStyle(color: _white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Reçu de Paiement', style: pw.TextStyle(color: PdfColor.fromHex('#C8E6C9'), fontSize: 9)),
            ]),
          ),
          pw.SizedBox(height: 20),

          // Montant
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 16),
            child: pw.Column(children: [
              pw.Text('MONTANT PAYÉ', style: pw.TextStyle(color: _grey, fontSize: 9)),
              pw.SizedBox(height: 4),
              pw.Text(currency == 'USD' ? '\$$amount' : '${amount.toStringAsFixed(0)} $currency',
                style: pw.TextStyle(color: _greenDark, fontSize: 28, fontWeight: pw.FontWeight.bold)),
            ]),
          ),

          pw.Divider(color: PdfColor.fromHex('#C8E6C9')),
          pw.SizedBox(height: 12),

          // Détails
          _receiptRow('Référence', reference),
          _receiptRow('Méthode', method),
          _receiptRow('Description', description),
          if (lotId != null) _receiptRow('Lot', lotId),
          _receiptRow('Date', DateFormat('dd/MM/yyyy HH:mm').format(date)),
          if (receiptNumber != null) _receiptRow('N° Reçu', receiptNumber),

          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColor.fromHex('#C8E6C9')),
          pw.SizedBox(height: 12),

          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(color: _greenPale, borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Row(children: [
              pw.Text('✓ ', style: pw.TextStyle(color: _green, fontSize: 12)),
              pw.Text('Paiement confirmé', style: pw.TextStyle(color: _green, fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ]),
          ),
          pw.SizedBox(height: 12),
          pw.Text('GreenSpace Togo · Merci pour votre confiance',
            style: pw.TextStyle(color: _grey, fontSize: 8)),
        ],
      ),
    ));

    return pdf.save();
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  static String _shortHash(String hash) {
    if (hash.length <= 20) return hash;
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 8)}';
  }

  static pw.TableRow _tableRow(String k1, String v1, String k2, String v2) {
    return pw.TableRow(children: [
      _cell(k1, isHeader: true), _cell(v1), _cell(k2, isHeader: true), _cell(v2),
    ]);
  }

  static pw.Widget _cell(String text, {bool isHeader = false}) => pw.Container(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(text, style: pw.TextStyle(
      fontSize: 9,
      color: isHeader ? PdfColor.fromHex('#546E7A') : PdfColor.fromHex('#1A2E1A'),
      fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
    )),
  );

  static pw.Widget _blockchainRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(children: [
      pw.SizedBox(width: 120,
        child: pw.Text(label, style: pw.TextStyle(color: PdfColor.fromHex('#7B5EA7'), fontSize: 8))),
      pw.Text(value, style: pw.TextStyle(color: PdfColor.fromHex('#1A1A2E'), fontSize: 8, fontWeight: pw.FontWeight.bold)),
    ]),
  );

  static pw.Widget _sectionTitle(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(title,
      style: pw.TextStyle(color: PdfColor.fromHex('#1B5E20'), fontSize: 12, fontWeight: pw.FontWeight.bold)),
  );

  static pw.Widget _infoTable(List<List<String>> rows) => pw.Table(
    border: pw.TableBorder.all(color: PdfColor.fromHex('#C8E6C9'), width: 0.5),
    columnWidths: {0: const pw.FixedColumnWidth(130), 1: const pw.FlexColumnWidth()},
    children: rows.map((r) => pw.TableRow(children: [
      pw.Container(padding: const pw.EdgeInsets.all(6),
        color: PdfColor.fromHex('#F1F8E9'),
        child: pw.Text(r[0], style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2E7D32')))),
      pw.Container(padding: const pw.EdgeInsets.all(6),
        child: pw.Text(r[1], style: const pw.TextStyle(fontSize: 9))),
    ])).toList(),
  );

  static pw.Widget _receiptRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text(label, style: pw.TextStyle(color: PdfColor.fromHex('#546E7A'), fontSize: 9)),
      pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
    ]),
  );
}
