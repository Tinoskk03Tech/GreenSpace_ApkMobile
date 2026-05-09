import 'package:flutter/material.dart';
import '../theme/gs_theme.dart';
import '../models/models.dart';
import '../services/payment_service.dart';
import '../services/document_service.dart';
import 'package:printing/printing.dart';

class PaymentScreen extends StatefulWidget {
  final PaymentType type;
  final String? lotId;
  final String description;

  const PaymentScreen({
    super.key,
    required this.type,
    this.lotId,
    required this.description,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  PaymentMethod? _selected;
  final _accountCtrl = TextEditingController();
  final _otpCtrl     = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;
  int _step = 0; // 0=choose, 1=details, 2=otp, 3=success
  bool _loading = false;
  PaymentTransaction? _transaction;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnim = Tween<double>(begin: 0.06, end: 0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _accountCtrl.dispose(); _otpCtrl.dispose(); _animCtrl.dispose();
    super.dispose();
  }

  double get _amount => widget.type.amount;
  String get _currency => _selected?.currency ?? 'XOF';

  void _selectMethod(PaymentMethod m) {
    setState(() { _selected = m; _step = 1; });
    _animCtrl.forward(from: 0);
  }

  void _confirmDetails() async {
    if (_accountCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez saisir vos informations de compte'),
        backgroundColor: GS.statusBad));
      return;
    }
    setState(() { _loading = true; });
    _transaction = await PaymentService.initiatePayment(
      method: _selected!,
      type: widget.type,
      amount: _amount,
      currency: _currency,
      description: widget.description,
      lotId: widget.lotId,
      accountInfo: _accountCtrl.text,
    );
    setState(() { _loading = false; _step = 2; });
    _animCtrl.forward(from: 0);
  }

  void _validateOtp() async {
    if (_otpCtrl.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Code OTP invalide (min 4 chiffres)'),
        backgroundColor: GS.statusBad));
      return;
    }
    setState(() => _loading = true);
    await PaymentService.confirmPayment(_transaction!.id);
    setState(() { _loading = false; _step = 3; });
    _animCtrl.forward(from: 0);
  }

  void _downloadReceipt() async {
    if (_transaction == null) return;
    final bytes = await PdfService.generatePaymentReceipt(
      reference: _transaction!.reference,
      method: _transaction!.method.label,
      amount: _transaction!.amount,
      currency: _transaction!.currency,
      description: _transaction!.description,
      date: _transaction!.completedAt ?? DateTime.now(),
      lotId: _transaction!.lotId,
      receiptNumber: _transaction!.receiptNumber,
    );
    await Printing.sharePdf(bytes: bytes, filename: 'recu_${_transaction!.reference}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Scaffold(
      backgroundColor: gs.bg,
      appBar: AppBar(
        backgroundColor: gs.bg,
        elevation: 0,
        leading: _step == 0
            ? GestureDetector(
                onTap: () => Navigator.pop(context),
                child: _backBtn(gs))
            : GestureDetector(
                onTap: () => setState(() {
                  _step = _step > 0 ? _step - 1 : 0;
                  _animCtrl.forward(from: 0);
                }),
                child: _backBtn(gs)),
        title: Text(
          ['Choisir un moyen de paiement', 'Informations de paiement',
           'Confirmation OTP', 'Paiement réussi'][_step],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: gs.textDark)),
      ),
      body: AnimatedBuilder(
        animation: _slideAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _slideAnim.value * 40),
          child: Opacity(opacity: 1 - _slideAnim.value, child: child),
        ),
        child: _buildStep(gs),
      ),
    );
  }

  Widget _backBtn(GSColors gs) => Container(
    margin: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)]),
    child: Icon(Icons.arrow_back_ios_new, size: 16, color: gs.textDark),
  );

  Widget _buildStep(GSColors gs) {
    switch (_step) {
      case 0: return _stepChoose(gs);
      case 1: return _stepDetails(gs);
      case 2: return _stepOtp(gs);
      case 3: return _stepSuccess(gs);
      default: return _stepChoose(gs);
    }
  }

  // ── Étape 1 : Choisir méthode ──────────────────────────────────────────
  Widget _stepChoose(GSColors gs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Montant à payer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [GS.greenPrimary, GS.greenDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: GS.greenDark.withOpacity(0.3), blurRadius: 12, offset: const Offset(0,5))],
            ),
            child: Column(children: [
              Text('Montant à payer', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
              const SizedBox(height: 8),
              Text('${_amount.toStringAsFixed(0)} XOF',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(widget.type.label,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              if (widget.lotId != null) ...[
                const SizedBox(height: 4),
                Text(widget.lotId!,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
              ],
            ]),
          ),
          const SizedBox(height: 24),

          Text('Choisissez votre méthode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: gs.textDark)),
          const SizedBox(height: 14),

          // Grille méthodes de paiement
          ...PaymentMethod.values.map((m) => _MethodTile(
            method: m,
            onTap: () => _selectMethod(m),
            gs: gs,
          )),

          const SizedBox(height: 20),
          // Historique des paiements
          if (PaymentService.history.isNotEmpty) ...[
            Text('Derniers paiements', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: gs.textDark)),
            const SizedBox(height: 10),
            ...PaymentService.history.take(3).map((t) => _HistoryTile(tx: t, gs: gs)),
          ],
        ],
      ),
    );
  }

  // ── Étape 2 : Détails compte ───────────────────────────────────────────
  Widget _stepDetails(GSColors gs) {
    final m = _selected!;
    final methodColor = _methodColor(m);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Badge méthode
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: methodColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: methodColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(width: 52, height: 52,
                  decoration: BoxDecoration(color: methodColor, borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(m.logo, style: const TextStyle(fontSize: 28)))),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: gs.textDark)),
                  Text(m.description, style: TextStyle(fontSize: 12, color: gs.textLight)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${_amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: methodColor)),
                  Text(_currency, style: TextStyle(fontSize: 11, color: gs.textLight)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Champ compte
          Align(alignment: Alignment.centerLeft,
            child: Text('Votre numéro / compte', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: gs.textDark))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: gs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: methodColor.withOpacity(0.4)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: TextField(
              controller: _accountCtrl,
              keyboardType: m == PaymentMethod.paypal
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              style: TextStyle(fontSize: 15, color: gs.textDark, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: m.hint,
                hintStyle: TextStyle(color: gs.textLight, fontSize: 13, fontWeight: FontWeight.normal),
                prefixIcon: Icon(m == PaymentMethod.paypal ? Icons.email_outlined : Icons.phone_outlined,
                  color: methodColor, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Note info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GS.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GS.gold.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: GS.gold, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(
                m == PaymentMethod.tmoney || m == PaymentMethod.flooz
                    ? 'Un SMS de confirmation vous sera envoyé sur ce numéro.'
                    : m == PaymentMethod.paypal
                        ? 'Vous recevrez un email de confirmation PayPal.'
                        : 'Vous recevrez un code de confirmation par SMS ou email.',
                style: TextStyle(fontSize: 11, color: gs.textMed))),
            ]),
          ),
          const SizedBox(height: 28),

          _PayBtn(
            label: 'Continuer',
            color: methodColor,
            loading: _loading,
            onTap: _confirmDetails,
          ),
        ],
      ),
    );
  }

  // ── Étape 3 : OTP ─────────────────────────────────────────────────────
  Widget _stepOtp(GSColors gs) {
    final methodColor = _methodColor(_selected!);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: methodColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: methodColor.withOpacity(0.3), width: 2),
            ),
            child: Icon(Icons.lock_outline_rounded, color: methodColor, size: 36),
          ),
          const SizedBox(height: 20),
          Text('Vérification OTP',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: gs.textDark)),
          const SizedBox(height: 8),
          Text(
            _selected == PaymentMethod.paypal
                ? 'Un code a été envoyé à votre adresse PayPal'
                : 'Un code OTP a été envoyé au\n${_accountCtrl.text}',
            style: TextStyle(fontSize: 13, color: gs.textLight, height: 1.5),
            textAlign: TextAlign.center),
          const SizedBox(height: 32),

          // Champ OTP
          Container(
            decoration: BoxDecoration(
              color: gs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: methodColor.withOpacity(0.4)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
            ),
            child: TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900,
                color: gs.textDark, letterSpacing: 12),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: TextStyle(color: gs.textLight, letterSpacing: 12, fontSize: 24),
                counterText: '',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Text('Renvoyer le code',
              style: TextStyle(color: methodColor, fontSize: 13, fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline)),
          ),
          const SizedBox(height: 32),
          _PayBtn(label: 'Valider le paiement', color: methodColor, loading: _loading, onTap: _validateOtp),
        ],
      ),
    );
  }

  // ── Étape 4 : Succès ──────────────────────────────────────────────────
  Widget _stepSuccess(GSColors gs) {
    final tx = _transaction;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Animation succès
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (_, v, __) => Transform.scale(scale: v,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: GS.statusOk.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: GS.statusOk, width: 3),
                ),
                child: const Icon(Icons.check_rounded, color: GS.statusOk, size: 46),
              )),
          ),
          const SizedBox(height: 20),
          Text('Paiement Confirmé !',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: gs.textDark)),
          const SizedBox(height: 6),
          Text('${tx?.formattedAmount ?? _amount} payé via ${_selected?.label}',
            style: TextStyle(fontSize: 13, color: gs.textLight), textAlign: TextAlign.center),
          const SizedBox(height: 28),

          // Récapitulatif
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: gs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gs.divider),
            ),
            child: Column(
              children: [
                _successRow('Référence', tx?.reference ?? '--', gs),
                _successRow('Méthode', _selected?.label ?? '--', gs),
                _successRow('Montant', tx?.formattedAmount ?? '--', gs),
                _successRow('Statut', 'Payé ✓', gs, valueColor: GS.statusOk),
                if (tx?.receiptNumber != null)
                  _successRow('N° Reçu', tx!.receiptNumber!, gs),
                _successRow('Date', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', gs),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Boutons
          _PayBtn(
            label: 'Télécharger le reçu',
            color: GS.greenPrimary,
            icon: Icons.download_rounded,
            onTap: _downloadReceipt,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              width: double.infinity, height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: gs.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text('Fermer',
                style: TextStyle(fontSize: 15, color: gs.textMed, fontWeight: FontWeight.w600))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _successRow(String label, String value, GSColors gs, {Color? valueColor}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 13, color: gs.textLight)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
          color: valueColor ?? gs.textDark)),
      ]));

  Color _methodColor(PaymentMethod m) => switch(m) {
    PaymentMethod.tmoney  => GS.tmoney,
    PaymentMethod.flooz   => GS.flooz,
    PaymentMethod.ecobank => GS.ecobank,
    PaymentMethod.poste   => GS.poste,
    PaymentMethod.paypal  => GS.paypal,
  };
}

// ── Method Tile ───────────────────────────────────────────────────────────
class _MethodTile extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onTap;
  final GSColors gs;
  const _MethodTile({required this.method, required this.onTap, required this.gs});

  Color get color => switch(method) {
    PaymentMethod.tmoney  => GS.tmoney,
    PaymentMethod.flooz   => GS.flooz,
    PaymentMethod.ecobank => GS.ecobank,
    PaymentMethod.poste   => GS.poste,
    PaymentMethod.paypal  => GS.paypal,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0,2))],
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(method.logo, style: const TextStyle(fontSize: 24)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(method.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: gs.textDark)),
              Text(method.description, style: TextStyle(fontSize: 11, color: gs.textLight)),
            ])),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: gs.textLight),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final PaymentTransaction tx;
  final GSColors gs;
  const _HistoryTile({required this.tx, required this.gs});

  @override
  Widget build(BuildContext context) {
    final isOk = tx.status == PaymentStatus.success;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: gs.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gs.divider.withOpacity(0.5)),
      ),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(
            color: (isOk ? GS.statusOk : GS.statusWait).withOpacity(0.12),
            borderRadius: BorderRadius.circular(9)),
          child: Icon(isOk ? Icons.check_circle_outline : Icons.hourglass_empty,
            color: isOk ? GS.statusOk : GS.statusWait, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.reference, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: gs.textDark)),
          Text('${tx.method.label} · ${tx.description}',
            style: TextStyle(fontSize: 10, color: gs.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(tx.formattedAmount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
            color: isOk ? GS.statusOk : GS.statusWait)),
          Text(tx.statusLabel, style: const TextStyle(fontSize: 9, color: GS.statusOk)),
        ]),
      ]),
    );
  }
}

class _PayBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool loading;
  final VoidCallback? onTap;
  const _PayBtn({required this.label, required this.color, this.icon, this.loading = false, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: double.infinity, height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, offset: const Offset(0,4))],
      ),
      child: Center(
        child: loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[Icon(icon, color: Colors.white, size: 19), const SizedBox(width: 8)],
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ]),
      ),
    ),
  );
}
