import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════════════════════════════════════
// APP PROVIDER — thème + langue + notifications (tout en un)
// ══════════════════════════════════════════════════════════════════════════
enum AppLang { fr, en, ewe }

class AppProvider extends ChangeNotifier {
  bool    _isDark       = false;
  AppLang _lang         = AppLang.fr;
  bool    _notifsOn     = true;

  bool    get isDark     => _isDark;
  AppLang get lang       => _lang;
  bool    get notifsOn   => _notifsOn;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  AppProvider() { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _isDark   = p.getBool('dark_mode')  ?? false;
    _notifsOn = p.getBool('notifs_on')  ?? true;
    final langIdx = p.getInt('lang')    ?? 0;
    _lang = AppLang.values[langIdx.clamp(0, AppLang.values.length - 1)];
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final p = await SharedPreferences.getInstance();
    await p.setBool('dark_mode', _isDark);
    notifyListeners();
  }

  Future<void> setLang(AppLang l) async {
    _lang = l;
    final p = await SharedPreferences.getInstance();
    await p.setInt('lang', l.index);
    notifyListeners();
  }

  Future<void> toggleNotifs() async {
    _notifsOn = !_notifsOn;
    final p = await SharedPreferences.getInstance();
    await p.setBool('notifs_on', _notifsOn);
    notifyListeners();
  }

  // Traductions (FR / EN / Ewe)
  String t(String key) => _translations[_lang]?[key] ?? _translations[AppLang.fr]![key] ?? key;
}

// ── Dictionnaire de traductions ────────────────────────────────────────────
const Map<AppLang, Map<String, String>> _translations = {
  AppLang.fr: {
    // Navigation
    'nav_home': 'Accueil', 'nav_agri': 'Agriculture', 'nav_coop': 'Coopérative',
    'nav_transfo': 'Transfo.', 'nav_export': 'Export', 'nav_verif': 'Vérif.',
    // Auth
    'your_profile': 'VOTRE PROFIL', 'login_page': 'PAGE DE CONNEXION',
    'register_page': "PAGE D'INSCRIPTION", 'connect': 'Se connecter',
    'register': "S'inscrire", 'already_account': 'Déjà un compte ? Se connecter',
    'no_account': "Pas encore de compte ? S'inscrire",
    'enter_id': 'Entrer votre identifiant', 'enter_name': 'Entrer votre nom',
    'enter_email': 'Entrer votre email', 'enter_phone': 'Entrer votre numéro tél',
    'enter_region': 'Entrer votre région', 'enter_password': 'Entrer votre mot de passe',
    // Dashboard
    'national_dashboard': 'Dashboard National', 'ministry': "Ministère de l'Agriculture - Togo",
    'lots_registered': 'Lots enregistrés', 'exporters': 'Exportateurs',
    'certifications': 'Certifications', 'active_zones': 'Zones actives',
    'farmers': 'Agriculteurs', 'production_zones': 'Zones de production',
    'zones_map': 'Carte des zones', 'monthly_production': 'Production mensuelle (tonnes)',
    'cert_repartition': 'Répartition certifications', 'social_impact': 'Impact social et économique',
    // Agriculture
    'register_lot': 'Enregistrer un nouveau lot', 'ejok_trace': 'Enregistrer votre récolte pour la traçabilité EJOK',
    'geolocation': 'Géolocalisation', 'get_position': 'Obtenir ma position',
    'lot_weight': 'Poids du lot (kg)', 'culture_type': 'Type de culture',
    'harvest_date': 'Date de récolte', 'save_lot': 'Enregistrer le lot',
    'lot_saved': 'Lot enregistré avec succès !',
    // Rôles
    'role_agri': 'Agriculteur', 'role_export': 'Exportateur',
    'role_verif': 'Vérificateur', 'role_transfo': 'Transformateur',
    'role_coop': 'Coopérative',
    'role_agriculteur': 'Agriculteur', 'role_exportateur': 'Exportateur',
    'role_verificateur': 'Vérificateur', 'role_transformateur': 'Transformateur',
    'role_cooperative': 'Coopérative',
    // Compte
    'my_account': 'Mon Compte', 'my_profile': 'Profil', 'payments': 'Paiements',
    'settings': 'Paramètres', 'edit': 'Modifier', 'cancel': 'Annuler',
    'save_changes': 'Enregistrer les modifications', 'logout': 'Se déconnecter',
    'dark_mode': 'Mode Sombre', 'light_mode': 'Mode Clair',
    'language': 'Langue', 'notifications': 'Notifications',
    'dark_mode_on': 'Interface sombre activée', 'light_mode_on': 'Interface claire activée',
    'appearance': 'Apparence', 'security': 'Sécurité & Confidentialité',
    'help': 'Aide & Support', 'about': 'À propos de GreenSpace',
    // Permissions
    'no_permission': 'Accès non autorisé',
    'agri_only': "Seul un Agriculteur peut enregistrer un lot.",
    'verif_only': "Seul un Vérificateur peut certifier des lots.",
    'transfo_only': "Seul un Transformateur peut valider la transformation.",
    'export_only': "Seul un Exportateur peut gérer les exports.",
    'coop_only': "Seul une Coopérative peut gérer les transferts.",
    // Misc
    'lots': 'Lots', 'verified': 'Vérifiés', 'exported': 'Exportés',
    'all_lots': 'Tous les lots', 'transfer': 'Transférer', 'details': 'Détails',
    'search': 'Rechercher', 'scan_qr': 'Scanner un QR Code',
    'lot_id': 'ID du lot', 'lot_id_hint': 'LOT-TG-2026-XXXX',
  },
  AppLang.en: {
    // Navigation
    'nav_home': 'Home', 'nav_agri': 'Farming', 'nav_coop': 'Cooperative',
    'nav_transfo': 'Process.', 'nav_export': 'Export', 'nav_verif': 'Verify',
    // Auth
    'your_profile': 'YOUR PROFILE', 'login_page': 'LOGIN PAGE',
    'register_page': 'REGISTRATION PAGE', 'connect': 'Sign In',
    'register': 'Sign Up', 'already_account': 'Already have an account? Sign In',
    'no_account': "Don't have an account? Sign Up",
    'enter_id': 'Enter your username', 'enter_name': 'Enter your name',
    'enter_email': 'Enter your email', 'enter_phone': 'Enter your phone number',
    'enter_region': 'Enter your region', 'enter_password': 'Enter your password',
    // Dashboard
    'national_dashboard': 'National Dashboard', 'ministry': 'Ministry of Agriculture - Togo',
    'lots_registered': 'Registered Lots', 'exporters': 'Exporters',
    'certifications': 'Certifications', 'active_zones': 'Active Zones',
    'farmers': 'Farmers', 'production_zones': 'Production Zones',
    'zones_map': 'Zones Map', 'monthly_production': 'Monthly Production (tons)',
    'cert_repartition': 'Certification Distribution', 'social_impact': 'Social & Economic Impact',
    // Agriculture
    'register_lot': 'Register a new lot', 'ejok_trace': 'Register your harvest for EJOK traceability',
    'geolocation': 'Geolocation', 'get_position': 'Get my position',
    'lot_weight': 'Lot weight (kg)', 'culture_type': 'Crop type',
    'harvest_date': 'Harvest date', 'save_lot': 'Save lot',
    'lot_saved': 'Lot saved successfully!',
    // Rôles
    'role_agri': 'Farmer', 'role_export': 'Exporter',
    'role_verif': 'Verifier', 'role_transfo': 'Processor',
    'role_coop': 'Cooperative',
    'role_agriculteur': 'Farmer', 'role_exportateur': 'Exporter',
    'role_verificateur': 'Verifier', 'role_transformateur': 'Processor',
    'role_cooperative': 'Cooperative',
    // Compte
    'my_account': 'My Account', 'my_profile': 'Profile', 'payments': 'Payments',
    'settings': 'Settings', 'edit': 'Edit', 'cancel': 'Cancel',
    'save_changes': 'Save changes', 'logout': 'Sign Out',
    'dark_mode': 'Dark Mode', 'light_mode': 'Light Mode',
    'language': 'Language', 'notifications': 'Notifications',
    'dark_mode_on': 'Dark interface enabled', 'light_mode_on': 'Light interface enabled',
    'appearance': 'Appearance', 'security': 'Security & Privacy',
    'help': 'Help & Support', 'about': 'About GreenSpace',
    // Permissions
    'no_permission': 'Access Denied',
    'agri_only': 'Only a Farmer can register a lot.',
    'verif_only': 'Only a Verifier can certify lots.',
    'transfo_only': 'Only a Processor can validate transformation.',
    'export_only': 'Only an Exporter can manage exports.',
    'coop_only': 'Only a Cooperative can manage transfers.',
    // Misc
    'lots': 'Lots', 'verified': 'Verified', 'exported': 'Exported',
    'all_lots': 'All lots', 'transfer': 'Transfer', 'details': 'Details',
    'search': 'Search', 'scan_qr': 'Scan QR Code',
    'lot_id': 'Lot ID', 'lot_id_hint': 'LOT-TG-2026-XXXX',
  },
  AppLang.ewe: {
    // Navigation
    'nav_home': 'Ƒomevi', 'nav_agri': 'Agble', 'nav_coop': 'Koperatif',
    'nav_transfo': 'Vɔvɔ', 'nav_export': 'Yigbe', 'nav_verif': 'Kpɔkpɔ',
    // Auth
    'your_profile': 'WO PROFIL', 'login_page': 'ŊKƆLƆŊLƆ',
    'register_page': 'WƆWƆ ŊKƆ', 'connect': 'Ŋlɔ',
    'register': 'Wɔ ŋkɔ', 'already_account': 'Ete ŋkɔ le? Ŋlɔ',
    'no_account': 'Meɖe ŋkɔ o? Wɔ ŋkɔ',
    'enter_id': 'Ŋlɔ wo ŋkɔ', 'enter_name': 'Ŋlɔ wo dzesi',
    'enter_email': 'Ŋlɔ wo email', 'enter_phone': 'Ŋlɔ wo telefɔn',
    'enter_region': 'Ŋlɔ wo ƒe', 'enter_password': 'Ŋlɔ faɖi',
    // Dashboard
    'national_dashboard': 'Dashboard Xexeame', 'ministry': 'Agble Ministri - Togo',
    'lots_registered': 'Lots siwo wɔ ŋkɔ', 'exporters': 'Yigbeawo',
    'certifications': 'Nyatakakawo', 'active_zones': 'Ƒewo si le dɔm',
    'farmers': 'Agbleawo', 'production_zones': 'Agble ƒewo',
    'zones_map': 'Mapa', 'monthly_production': 'Ɣleti dɔwɔwɔ',
    'cert_repartition': 'Nyatakaka kabakaba', 'social_impact': 'Gbɔgbɔzãzã',
    // Agriculture
    'register_lot': 'Wɔ lot ŋkɔ yeye', 'ejok_trace': 'Ŋlɔ wo haxɔ dzi EJOK',
    'geolocation': 'Ƒe siwo', 'get_position': 'Xɔ ma ƒe',
    'lot_weight': 'Lot trome (kg)', 'culture_type': 'Agble nu',
    'harvest_date': 'Haxɔ egbe', 'save_lot': 'Dzra lot',
    'lot_saved': 'Lot wɔ ŋkɔ nyuie!',
    // Rôles
    'role_agri': 'Agbleala', 'role_export': 'Yigbeala',
    'role_verif': 'Kpɔkpɔala', 'role_transfo': 'Vɔvɔala',
    'role_coop': 'Koperatif',
    'role_agriculteur': 'Agbleala', 'role_exportateur': 'Yigbeala',
    'role_verificateur': 'Kpɔkpɔala', 'role_transformateur': 'Vɔvɔala',
    'role_cooperative': 'Koperatif',
    // Compte
    'my_account': 'Nye akawunta', 'my_profile': 'Profil', 'payments': 'Sɛsɛsɛ',
    'settings': 'Ɖoɖowɔwɔ', 'edit': 'Tso gbɔ', 'cancel': 'Ɣe',
    'save_changes': 'Dzra gadzadzawo', 'logout': 'Gblẽ',
    'dark_mode': 'Dzɔdzɔ Mode', 'light_mode': 'Vevie Mode',
    'language': 'Gbe', 'notifications': 'Nusese',
    'dark_mode_on': 'Dzɔdzɔ mɔ le dɔm', 'light_mode_on': 'Vevie mɔ le dɔm',
    'appearance': 'Nɛnɛ', 'security': 'Blibo', 'help': 'Kpekpeɖeŋu', 'about': 'GreenSpace dzi',
    // Permissions
    'no_permission': 'Mele nuvɔnu o',
    'agri_only': 'Agbleala tso be ŋlɔ lot.',
    'verif_only': 'Kpɔkpɔala tso be da nyatakaka.',
    'transfo_only': 'Vɔvɔala tso be ŋlɔ vɔvɔ.',
    'export_only': 'Yigbeala tso be ɖɔ yigbe.',
    'coop_only': 'Koperatif tso be ɖɔ yigbe.',
    // Misc
    'lots': 'Lots', 'verified': 'Kpɔkpɔ', 'exported': 'Yigbe',
    'all_lots': 'Lots katã', 'transfer': 'Yigbe', 'details': 'Nuwuwu',
    'search': 'Ba', 'scan_qr': 'Kpɔ QR Code',
    'lot_id': 'Lot ID', 'lot_id_hint': 'LOT-TG-2026-XXXX',
  },
};

// ── Palette de couleurs statiques ──────────────────────────────────────────
class GS {
  static const Color greenDark    = Color(0xFF1B5E20);
  static const Color greenPrimary = Color(0xFF2E7D32);
  static const Color greenMid     = Color(0xFF388E3C);
  static const Color greenLight   = Color(0xFF4CAF50);
  static const Color greenPale    = Color(0xFFE8F5E9);
  static const Color greenCard    = Color(0xFFC8E6C9);
  static const Color brown        = Color(0xFF6D4C1F);
  static const Color brownDark    = Color(0xFF4E3010);
  static const Color polygon      = Color(0xFF8247E5);
  static const Color tmoney       = Color(0xFFE53935);
  static const Color flooz        = Color(0xFFFF6F00);
  static const Color ecobank      = Color(0xFF1B5E20);
  static const Color poste        = Color(0xFF1565C0);
  static const Color paypal       = Color(0xFF003087);
  static const Color statusNew    = Color(0xFF1976D2);
  static const Color statusOk     = Color(0xFF388E3C);
  static const Color statusWait   = Color(0xFFF57C00);
  static const Color statusBad    = Color(0xFFD32F2F);
  static const Color statusTrans  = Color(0xFF6D4C41);
  static const Color gold         = Color(0xFFF9A825);
  static const Color textDark     = Color(0xFF1A2E1A);
  static const Color textMed      = Color(0xFF3E5E3E);
  static const Color textLight    = Color(0xFF7A9A7A);
  static const Color bgScreen     = Color(0xFFF0F7EE);
  static const Color divider      = Color(0xFFB8D8B8);
  static const Color white        = Color(0xFFFFFFFF);

  // ── Light Theme ───────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: greenPrimary, secondary: brown,
      surface: white,
    ),
    scaffoldBackgroundColor: bgScreen,
    cardColor: white,
    dividerColor: divider,
    extensions: const [GSColors.light],
  );

  // ── Dark Theme ────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF66BB6A), secondary: Color(0xFFA1887F),
      surface: Color(0xFF1E2D1E),
    ),
    scaffoldBackgroundColor: const Color(0xFF0D1A0D),
    cardColor: const Color(0xFF1A2E1A),
    dividerColor: const Color(0xFF2A4A2A),
    extensions: const [GSColors.dark],
  );
}

// ── Theme Extension ────────────────────────────────────────────────────────
class GSColors extends ThemeExtension<GSColors> {
  final Color bg, surface, card, textDark, textMed, textLight,
              divider, inputFill, greenAccent, greenBg, shadow;

  const GSColors({
    required this.bg, required this.surface, required this.card,
    required this.textDark, required this.textMed, required this.textLight,
    required this.divider, required this.inputFill,
    required this.greenAccent, required this.greenBg, required this.shadow,
  });

  static const light = GSColors(
    bg:          Color(0xFFF0F7EE),
    surface:     Color(0xFFFFFFFF),
    card:        Color(0xFFFFFFFF),
    textDark:    Color(0xFF1A2E1A),
    textMed:     Color(0xFF3E5E3E),
    textLight:   Color(0xFF7A9A7A),
    divider:     Color(0xFFB8D8B8),
    inputFill:   Color(0xFFF0F7EE),
    greenAccent: Color(0xFF2E7D32),
    greenBg:     Color(0xFFE8F5E9),
    shadow:      Color(0x141B5E20),
  );

  static const dark = GSColors(
    bg:          Color(0xFF0D1A0D),
    surface:     Color(0xFF1A2E1A),
    card:        Color(0xFF1E3A1E),
    textDark:    Color(0xFFE8F5E9),
    textMed:     Color(0xFFB0CCB0),
    textLight:   Color(0xFF6A8A6A),
    divider:     Color(0xFF2A4A2A),
    inputFill:   Color(0xFF162816),
    greenAccent: Color(0xFF66BB6A),
    greenBg:     Color(0xFF162816),
    shadow:      Color(0x28000000),
  );

  @override
  GSColors copyWith({
    Color? bg, Color? surface, Color? card, Color? textDark,
    Color? textMed, Color? textLight, Color? divider, Color? inputFill,
    Color? greenAccent, Color? greenBg, Color? shadow,
  }) => GSColors(
    bg: bg ?? this.bg, surface: surface ?? this.surface, card: card ?? this.card,
    textDark: textDark ?? this.textDark, textMed: textMed ?? this.textMed,
    textLight: textLight ?? this.textLight, divider: divider ?? this.divider,
    inputFill: inputFill ?? this.inputFill, greenAccent: greenAccent ?? this.greenAccent,
    greenBg: greenBg ?? this.greenBg, shadow: shadow ?? this.shadow,
  );

  @override
  GSColors lerp(GSColors? other, double t) {
    if (other == null) return this;
    return GSColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      textDark: Color.lerp(textDark, other.textDark, t)!,
      textMed: Color.lerp(textMed, other.textMed, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      greenAccent: Color.lerp(greenAccent, other.greenAccent, t)!,
      greenBg: Color.lerp(greenBg, other.greenBg, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

// ── Context extensions ─────────────────────────────────────────────────────
extension GSTheme on BuildContext {
  GSColors get gs => Theme.of(this).extension<GSColors>() ?? GSColors.light;
  bool get isDark  => Theme.of(this).brightness == Brightness.dark;
}
