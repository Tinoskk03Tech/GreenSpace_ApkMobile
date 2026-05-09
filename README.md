# 🌿 GreenSpace v2.0 — Traçabilité Agricole Togo
## Équipe TG-24 : Land of Programmers

### ✨ Nouvelles fonctionnalités v2.0

| Fonctionnalité | Description |
|---|---|
| 🌙 Mode Sombre/Clair | Toggle dans Compte > Paramètres, persisté via SharedPreferences |
| ⬡ Blockchain Polygon | Enregistrement des lots sur Polygon Mumbai, vérification de hash |
| 💳 Paiements | T-Money, Flooz, Ecobank, Poste Togo, PayPal avec OTP & reçu PDF |
| 🔲 QR Code EJOK | QR codes réels générés avec qr_flutter, données JSON enrichies |
| 📄 PDF Documents | Certificat export, rapport de lot, reçu paiement via pdf/printing |
| 👁 Détails Lot | Écran détaillé avec timeline, blockchain, paiements liés |
| 💼 Wallet Polygon | Adresse wallet auto-générée par utilisateur, solde MATIC |

### 📱 Pages de l'application (dans l'ordre)

1. **Splash** — Écran animé avec logo GreenSpace
2. **Sélection Rôle** — Agriculteur, Exportateur, Vérificateur, Transformateur, Coopérative
3. **Inscription** — Formulaire adapté par rôle
4. **Connexion** — Login avec dropdown rôle
5. **Accueil / Dashboard** — Stats nationales, carte, graphiques
6. **Agriculteur** — Enregistrement lot + GPS
7. **Coopérative** — Gestion et transfert des lots
8. **Transformateur** — Validation transformation
9. **Exportateur** — Exports + QR EJOK + PDF + Blockchain
10. **Vérificateur** — Scan QR + certifications
11. **Notifications** — Groupées, swipe-to-delete
12. **Compte** — Profil, paiements, paramètres + dark mode

### 🚀 Installation

```bash
# 1. Extraire le projet
cd greenspace

# 2. Installer les dépendances
flutter pub get

# 3. Lancer
flutter run
```

### 📦 Dépendances principales

| Package | Usage |
|---|---|
| `qr_flutter` | Génération QR codes EJOK |
| `pdf` + `printing` | Génération & partage PDF |
| `http` | API Polygon RPC |
| `crypto` | Hash SHA-256 blockchain |
| `shared_preferences` | Persistance dark mode |
| `provider` | State management thème |
| `intl` | Formatage dates dans PDF |

### 💳 Méthodes de paiement

- 📱 **T-Money** — Mobile Money Togocom (XOF)
- 📲 **Flooz** — Mobile Money Moov Africa (XOF)
- 🏦 **Ecobank** — Virement bancaire (XOF)
- ✉️ **Poste Togo** — Paiement postal (XOF)
- 💳 **PayPal** — Paiement international (USD)

### ⬡ Blockchain Polygon

- Réseau : **Polygon Mumbai Testnet** (→ Mainnet en production)
- Hash : **SHA-256** de toutes les données du lot
- Explorer : **mumbai.polygonscan.com**
- Contrat : Smart contract de traçabilité

### 🗂️ Structure

```
lib/
├── main.dart                    ← Entry point + Provider
├── theme/gs_theme.dart          ← Light/Dark theme + ThemeProvider
├── models/models.dart           ← Entités + AppState
├── services/
│   ├── blockchain_service.dart  ← Polygon RPC + hash
│   ├── document_service.dart    ← QR data + PDF generation
│   └── payment_service.dart     ← 5 méthodes de paiement
├── widgets/widgets.dart         ← Composants réutilisables
└── screens/
    ├── auth_screens.dart         ← Splash + Rôle + Register + Login
    ├── main_shell.dart           ← Shell + bottom nav
    ├── dashboard_screen.dart     ← Accueil national
    ├── agriculteur_screen.dart   ← Enregistrement lot
    ├── cooperative_screen.dart   ← Gestion coopérative
    ├── transformateur_screen.dart
    ├── exportateur_screen.dart   ← QR + PDF + Export
    ├── verificateur_screen.dart  ← Scan + certifications
    ├── blockchain_screen.dart    ← Wallet + lots + vérif
    ├── payment_screen.dart       ← 5 méthodes + OTP
    ├── lot_detail_screen.dart    ← Détails complets + timeline
    ├── notifications_screen.dart
    └── compte_screen.dart        ← Profil + paiements + dark mode
```
