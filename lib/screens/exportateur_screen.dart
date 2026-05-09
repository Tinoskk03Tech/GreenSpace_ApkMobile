import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import '../theme/gs_theme.dart';
import '../widgets/role_guard.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../services/blockchain_service.dart';
import '../services/document_service.dart';
import '../services/payment_service.dart';
import 'payment_screen.dart';
import 'blockchain_screen.dart';
import 'lot_detail_screen.dart';

class ExportateurScreen extends StatelessWidget {
  const ExportateurScreen({super.key});
  @override
  Widget build(BuildContext context) => RoleGuard(
        required: UserRole.exportateur,
        child: const _ExportBody(),
      );
}

class _ExportBody extends StatefulWidget {
  const _ExportBody();
  @override
  State<_ExportBody> createState() => _ExportBodyState();
}

class _ExportBodyState extends State<_ExportBody> {
  bool _generatingPdf = false;

  void _exporter(LotModel lot) async {
    final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
              type: PaymentType.export,
              lotId: lot.lotId,
              description: 'Export ${lot.lotId}'),
        ));
    if (paid == true) {
      setState(() {
        lot.status = LotStatus.exporte;
        lot.exportateurNom = AppState.user?.fullName ?? 'Exportateur';
      });
    }
  }

  void _generateQr(LotModel lot) {
    final gs = context.gs;
    final data = QrCodeService.generateEjokQrData(
        lot: lot,
        blockchain: lot.blockchainRecord,
        exportateur: AppState.user?.fullName);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
            color: gs.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: gs.divider,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('QR Code EJOK — ${lot.lotId}',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: gs.textDark)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.12), blurRadius: 12)
                ]),
            child: QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 200,
                eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square, color: Color(0xFF1B5E20)),
                dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF2E7D32))),
          ),
          const SizedBox(height: 12),
          Text('Scan pour vérifier • greenspace.tg/verify/${lot.lotId}',
              style: TextStyle(fontSize: 11, color: gs.textLight)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _downloadCert(lot);
              },
              child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                      color: GS.greenPrimary,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Certificat PDF',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ])),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _downloadReport(lot);
              },
              child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                      color: gs.inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: gs.divider)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined,
                            color: gs.textMed, size: 18),
                        const SizedBox(width: 8),
                        Text('Rapport',
                            style: TextStyle(
                                color: gs.textMed,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ])),
            )),
          ]),
        ]),
      ),
    );
  }

  void _downloadCert(LotModel lot) async {
    setState(() => _generatingPdf = true);
    try {
      final bytes = await PdfService.generateExportCertificate(
          lot: lot,
          exportateur: AppState.user?.fullName ?? 'Exportateur',
          blockchain: lot.blockchainRecord);
      await Printing.sharePdf(
          bytes: bytes, filename: 'certificat_${lot.lotId}.pdf');
    } finally {
      setState(() => _generatingPdf = false);
    }
  }

  void _downloadReport(LotModel lot) async {
    setState(() => _generatingPdf = true);
    try {
      final bytes = await PdfService.generateLotReport(
          lot: lot, blockchain: lot.blockchainRecord);
      await Printing.sharePdf(
          bytes: bytes, filename: 'rapport_${lot.lotId}.pdf');
    } finally {
      setState(() => _generatingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    final disponibles = AppState.lots
        .where((l) =>
            l.status == LotStatus.enTransformation ||
            l.status == LotStatus.verifie)
        .toList();
    final exportes =
        AppState.lots.where((l) => l.status == LotStatus.exporte).toList();
    final totalPoids = disponibles.fold<double>(0, (s, l) => s + l.poids);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageBanner(
            emoji: '🚢',
            title: 'Gestion des exports',
            subtitle: 'Exportateur agréé — Togo'),
        const SizedBox(height: 16),
        Row(children: [
          _Stat(
              label: 'Prêts',
              value: '${disponibles.length}',
              unit: 'Lots',
              color: GS.greenPrimary,
              gs: gs),
          const SizedBox(width: 10),
          _Stat(
              label: 'Total',
              value: '${totalPoids.toInt()}',
              unit: 'kg',
              color: GS.brown,
              gs: gs),
          const SizedBox(width: 10),
          _Stat(
              label: 'Exportés',
              value: '${exportes.length}',
              unit: 'Lots',
              color: GS.polygon,
              gs: gs),
        ]),
        const SizedBox(height: 16),
        // Blockchain banner
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BlockchainScreen())),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF8247E5), Color(0xFF6B35C9)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: GS.polygon.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Row(children: [
              Text('⬡', style: TextStyle(color: Colors.white, fontSize: 24)),
              SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Blockchain Polygon',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                    Text('Enregistrer, vérifier vos lots sur Polygon',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ])),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 14),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        SectionHeader(title: 'Lots disponibles pour export', gs: gs),
        const SizedBox(height: 12),
        if (disponibles.isEmpty)
          Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: gs.surface, borderRadius: BorderRadius.circular(14)),
              child: Center(
                  child: Text('Aucun lot disponible',
                      style: TextStyle(color: gs.textLight, fontSize: 13))))
        else
          ...disponibles.map((lot) => _LotCard(
                lot: lot,
                gs: gs,
                onDetail: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LotDetailScreen(lot: lot))),
                onQr: () => _generateQr(lot),
                onDownload: () => _downloadCert(lot),
                onExport: () => _exporter(lot),
              )),

        if (_generatingPdf)
          Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: gs.surface, borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: GS.greenPrimary)),
                SizedBox(width: 10),
                Text('Génération du document...',
                    style: TextStyle(color: GS.greenPrimary, fontSize: 13)),
              ])),

        // Générateur QR
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: gs.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: GS.polygon.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.qr_code_2_rounded,
                      color: GS.polygon, size: 20)),
              const SizedBox(width: 10),
              Text('Générateur QR Code EJOK',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: gs.textDark)),
            ]),
            const SizedBox(height: 14),
            ...exportes.take(3).map((lot) => GestureDetector(
                  onTap: () => _generateQr(lot),
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: gs.inputFill,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: GS.polygon.withOpacity(0.2))),
                      child: Row(children: [
                        const Icon(Icons.qr_code_scanner_rounded,
                            color: GS.polygon, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(lot.lotId,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: gs.textDark)),
                              Text('${lot.culture} · ${lot.poids.toInt()} kg',
                                  style: TextStyle(
                                      fontSize: 10, color: gs.textLight)),
                            ])),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: GS.polygon,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text('Générer',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700))),
                      ])),
                )),
            if (exportes.isEmpty)
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: gs.inputFill,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text('Exportez un lot pour générer son QR Code',
                          style:
                              TextStyle(color: gs.textLight, fontSize: 12)))),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
              child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                      border: Border.all(color: gs.divider),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_outlined,
                            color: gs.textMed, size: 18),
                        const SizedBox(width: 8),
                        Text('Télécharger tous les documents',
                            style: TextStyle(
                                color: gs.textMed,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ])),
            ),
          ]),
        ),

        if (exportes.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionHeader(title: 'Lots exportés', gs: gs),
          const SizedBox(height: 12),
          ...exportes.map((lot) => _LotCard(
                lot: lot,
                gs: gs,
                onDetail: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LotDetailScreen(lot: lot))),
                onQr: () => _generateQr(lot),
                onDownload: () => _downloadCert(lot),
              )),
        ],
      ]),
    );
  }
}

class _LotCard extends StatelessWidget {
  final LotModel lot;
  final GSColors gs;
  final VoidCallback? onDetail, onExport, onQr, onDownload;
  const _LotCard(
      {required this.lot,
      required this.gs,
      this.onDetail,
      this.onExport,
      this.onQr,
      this.onDownload});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
            color: gs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: lot.isOnBlockchain
                    ? GS.polygon.withOpacity(0.25)
                    : gs.divider.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lot.lotId,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: gs.textDark)),
                    Row(children: [
                      if (lot.isOnBlockchain)
                        Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: const Text('⬡',
                                style: TextStyle(
                                    color: GS.polygon, fontSize: 14))),
                      StatusBadge(status: lot.status),
                    ]),
                  ])),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                _c(lot.culture, gs),
                const SizedBox(width: 8),
                _c('${lot.poids.toInt()} kg', gs),
                const SizedBox(width: 8),
                _c(lot.region, gs),
              ])),
          if (lot.certifications.isNotEmpty)
            Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Wrap(
                    spacing: 6,
                    children: lot.certifications
                        .map((c) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: GS.greenPrimary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: GS.greenPrimary.withOpacity(0.2))),
                              child: Text(c,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: GS.greenPrimary)),
                            ))
                        .toList())),
          Divider(height: 1, color: gs.divider.withOpacity(0.5)),
          Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Row(children: [
                  _btn('👁 Détails', gs.greenBg, gs.greenAccent, onDetail),
                  const SizedBox(width: 8),
                  _btn('🔲 QR Code', GS.polygon.withOpacity(0.1), GS.polygon,
                      onQr),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  _btn('📄 Télécharger', GS.greenPrimary.withOpacity(0.1),
                      GS.greenPrimary, onDownload),
                  const SizedBox(width: 8),
                  onExport != null
                      ? _btnFilled(
                          'Exporter →', GS.brown, Colors.white, onExport)
                      : _btn('✓ Exporté', GS.statusOk.withOpacity(0.1),
                          GS.statusOk, null),
                ]),
              ])),
        ]),
      );

  Widget _c(String t, GSColors gs) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: gs.inputFill, borderRadius: BorderRadius.circular(6)),
      child: Text(t, style: TextStyle(fontSize: 10, color: gs.textMed)));

  Widget _btn(String l, Color bg, Color fg, VoidCallback? cb) => Expanded(
      child: GestureDetector(
          onTap: cb,
          child: Container(
              height: 38,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(9)),
              child: Center(
                  child: Text(l,
                      style: TextStyle(
                          color: fg,
                          fontSize: 12,
                          fontWeight: FontWeight.w700))))));

  Widget _btnFilled(String l, Color bg, Color fg, VoidCallback? cb) => Expanded(
      child: GestureDetector(
          onTap: cb,
          child: Container(
              height: 38,
              decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                        color: bg.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 3))
                  ]),
              child: Center(
                  child: Text(l,
                      style: TextStyle(
                          color: fg,
                          fontSize: 12,
                          fontWeight: FontWeight.w700))))));
}

class _Stat extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final GSColors gs;
  const _Stat(
      {required this.label,
      required this.value,
      required this.unit,
      required this.color,
      required this.gs});
  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: gs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 5,
                    offset: const Offset(0, 2))
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 10, color: gs.textLight)),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(width: 3),
              Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit,
                      style: TextStyle(fontSize: 10, color: gs.textMed))),
            ]),
          ])));
}
