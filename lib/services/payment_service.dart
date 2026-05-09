import 'dart:math';

// ── Payment Service ────────────────────────────────────────────────────────
enum PaymentMethod { tmoney, flooz, ecobank, poste, paypal }

extension PaymentMethodX on PaymentMethod {
  String get label => const {
    PaymentMethod.tmoney:  'T-Money',
    PaymentMethod.flooz:   'Flooz',
    PaymentMethod.ecobank: 'Ecobank',
    PaymentMethod.poste:   'Poste Togo',
    PaymentMethod.paypal:  'PayPal',
  }[this]!;

  String get logo => const {
    PaymentMethod.tmoney:  '📱',
    PaymentMethod.flooz:   '📲',
    PaymentMethod.ecobank: '🏦',
    PaymentMethod.poste:   '✉️',
    PaymentMethod.paypal:  '💳',
  }[this]!;

  String get description => const {
    PaymentMethod.tmoney:  'Paiement mobile Togocom',
    PaymentMethod.flooz:   'Mobile Money Moov Africa',
    PaymentMethod.ecobank: 'Virement bancaire Ecobank',
    PaymentMethod.poste:   'Paiement via Poste Togo',
    PaymentMethod.paypal:  'Paiement international PayPal',
  }[this]!;

  String get currency => this == PaymentMethod.paypal ? 'USD' : 'XOF';

  String get hint => const {
    PaymentMethod.tmoney:  'Ex: +228 90 XX XX XX',
    PaymentMethod.flooz:   'Ex: +228 97 XX XX XX',
    PaymentMethod.ecobank: 'Numéro de compte Ecobank',
    PaymentMethod.poste:   'Code postal ou compte',
    PaymentMethod.paypal:  'Email PayPal',
  }[this]!;
}

enum PaymentStatus { pending, processing, success, failed, refunded }

enum PaymentType { lotRegistration, certification, export, subscription, transfer }

extension PaymentTypeX on PaymentType {
  String get label => const {
    PaymentType.lotRegistration: 'Enregistrement de lot',
    PaymentType.certification:   'Certification',
    PaymentType.export:          'Export EJOK',
    PaymentType.subscription:    'Abonnement mensuel',
    PaymentType.transfer:        'Transfert coopérative',
  }[this]!;

  double get amount => const {
    PaymentType.lotRegistration: 500.0,
    PaymentType.certification:   2000.0,
    PaymentType.export:          5000.0,
    PaymentType.subscription:    3000.0,
    PaymentType.transfer:        1000.0,
  }[this]!;
}

class PaymentTransaction {
  final String id, reference;
  final PaymentMethod method;
  final PaymentType type;
  final double amount;
  final String currency;
  PaymentStatus status;
  final DateTime createdAt;
  DateTime? completedAt;
  final String? lotId;
  final String description;
  String? receiptNumber;

  PaymentTransaction({
    required this.id, required this.reference, required this.method,
    required this.type, required this.amount, required this.currency,
    required this.status, required this.createdAt, required this.description,
    this.completedAt, this.lotId, this.receiptNumber,
  });

  String get statusLabel => const {
    PaymentStatus.pending:    'En attente',
    PaymentStatus.processing: 'En cours',
    PaymentStatus.success:    'Payé',
    PaymentStatus.failed:     'Échoué',
    PaymentStatus.refunded:   'Remboursé',
  }[status]!;

  String get formattedAmount {
    if (currency == 'USD') return '\$${amount.toStringAsFixed(2)}';
    return '${amount.toStringAsFixed(0)} $currency';
  }
}

class PaymentService {
  static final List<PaymentTransaction> _history = [
    PaymentTransaction(
      id: '1', reference: 'GS-2026-001',
      method: PaymentMethod.tmoney, type: PaymentType.lotRegistration,
      amount: 500, currency: 'XOF',
      status: PaymentStatus.success,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Enregistrement LOT-TG-2026-1421',
      lotId: 'LOT-TG-2026-1421', receiptNumber: 'REC-001-2026',
    ),
    PaymentTransaction(
      id: '2', reference: 'GS-2026-002',
      method: PaymentMethod.ecobank, type: PaymentType.certification,
      amount: 2000, currency: 'XOF',
      status: PaymentStatus.success,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Certification Bio + Fair Trade',
      lotId: 'LOT-TG-2026-1421', receiptNumber: 'REC-002-2026',
    ),
    PaymentTransaction(
      id: '3', reference: 'GS-2026-003',
      method: PaymentMethod.paypal, type: PaymentType.export,
      amount: 15.0, currency: 'USD',
      status: PaymentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      description: 'Export LOT-TG-2026-9921',
      lotId: 'LOT-TG-2026-9921',
    ),
  ];

  static List<PaymentTransaction> get history => _history;

  static double get totalPaid => _history
      .where((t) => t.status == PaymentStatus.success && t.currency == 'XOF')
      .fold(0, (s, t) => s + t.amount);

  // ── Initier un paiement ────────────────────────────────────────────────
  static Future<PaymentTransaction> initiatePayment({
    required PaymentMethod method,
    required PaymentType type,
    required double amount,
    required String currency,
    required String description,
    String? lotId,
    String? accountInfo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final ref = 'GS-${DateTime.now().year}-${Random().nextInt(9999).toString().padLeft(4, '0')}';
    final tx = PaymentTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reference: ref,
      method: method,
      type: type,
      amount: amount,
      currency: currency,
      status: PaymentStatus.processing,
      createdAt: DateTime.now(),
      description: description,
      lotId: lotId,
    );
    _history.insert(0, tx);
    return tx;
  }

  // ── Confirmer un paiement (simulation OTP/validation) ─────────────────
  static Future<PaymentTransaction> confirmPayment(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final tx = _history.firstWhere((t) => t.id == transactionId);
    tx.status = PaymentStatus.success;
    tx.completedAt = DateTime.now();
    tx.receiptNumber = 'REC-${Random().nextInt(999).toString().padLeft(3, '0')}-${DateTime.now().year}';
    return tx;
  }

  // ── Résumé par méthode ─────────────────────────────────────────────────
  static Map<PaymentMethod, double> get summaryByMethod {
    final map = <PaymentMethod, double>{};
    for (final t in _history.where((t) => t.status == PaymentStatus.success)) {
      map[t.method] = (map[t.method] ?? 0) + t.amount;
    }
    return map;
  }
}
