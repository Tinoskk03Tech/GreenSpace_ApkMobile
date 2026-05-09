import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/gs_theme.dart';
import '../models/models.dart';
import '../widgets/gs_logo_widget.dart';
import 'main_shell.dart';

// ══════════════════════════════════════════════════════════════════════════
// FEUILLE DÉCORATIVE — reproduit exactement la maquette
// ══════════════════════════════════════════════════════════════════════════
class _Leaf extends StatelessWidget {
  final bool flipX;
  final bool flipY;
  final double size;
  final Color color;
  const _Leaf({this.flipX=false, this.flipY=false, this.size=200, required this.color});

  @override
  Widget build(BuildContext context) => Transform(
    alignment: Alignment.center,
    transform: Matrix4.identity()
      ..scale(flipX ? -1.0 : 1.0, flipY ? -1.0 : 1.0),
    child: SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _LeafPainter(color)),
    ),
  );
}

class _LeafPainter extends CustomPainter {
  final Color color;
  _LeafPainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    // Feuille courbe gauche
    final path = Path()
      ..moveTo(0, s.height)
      ..cubicTo(0, s.height * 0.35, s.width * 0.35, 0, s.width, 0)
      ..cubicTo(s.width * 0.65, s.height * 0.15, s.width * 0.2, s.height * 0.55, 0, s.height)
      ..close();
    canvas.drawPath(path, p);
    // Deuxième courbe (ombre)
    final p2 = Paint()..color = color.withOpacity(0.55)..style = PaintingStyle.fill;
    final path2 = Path()
      ..moveTo(s.width * 0.15, s.height)
      ..cubicTo(s.width * 0.1, s.height * 0.5, s.width * 0.5, s.height * 0.15, s.width * 0.85, 0)
      ..cubicTo(s.width * 0.55, s.height * 0.25, s.width * 0.25, s.height * 0.65, s.width * 0.15, s.height)
      ..close();
    canvas.drawPath(path2, p2);
  }
  @override bool shouldRepaint(_) => false;
}

// ── Background FULL SCREEN avec feuilles aux 4 coins ─────────────────────
class _AuthBackground extends StatelessWidget {
  final Widget child;
  const _AuthBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final leafColor = const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFD6EDCE),
      // On utilise un Stack sur tout l'écran — pas de padding, pas de SafeArea ici
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // ── Fond dégradé plein écran ─────────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFCBE8C3), Color(0xFFB8DDB0)],
                  ),
                ),
              ),
            ),

            // ── Feuille haut-gauche ───────────────────────────────────────
            Positioned(
              top: -30, left: -30,
              child: _Leaf(size: size.width * 0.55, color: leafColor.withOpacity(0.85)),
            ),

            // ── Feuille haut-droite ───────────────────────────────────────
            Positioned(
              top: -30, right: -30,
              child: _Leaf(flipX: true, size: size.width * 0.55, color: leafColor.withOpacity(0.85)),
            ),

            // ── Feuille bas-gauche ────────────────────────────────────────
            Positioned(
              bottom: -30, left: -30,
              child: _Leaf(flipY: true, size: size.width * 0.55, color: leafColor.withOpacity(0.85)),
            ),

            // ── Feuille bas-droite ────────────────────────────────────────
            Positioned(
              bottom: -30, right: -30,
              child: _Leaf(flipX: true, flipY: true, size: size.width * 0.55, color: leafColor.withOpacity(0.85)),
            ),

            // ── Contenu scrollable par-dessus ────────────────────────────
            child,
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SPLASH SCREEN
// ══════════════════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _scale = Tween(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.8, curve: Curves.elasticOut)));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _AuthBackground(
      child: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo SVG grand format
                    GSLogoWidget(
                      width: size.width * 0.52,
                      height: size.width * 0.52,
                      withText: false,
                    ),
                    const SizedBox(height: 24),
                    // Texte GREENSPACE stylisé (fidèle maquette : italique, bicolore)
                    GSLogoWidget(
                      width: size.width * 0.7,
                      textOnly: true,
                    ),
                    const SizedBox(height: 48),
                    const SizedBox(
                      width: 28, height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// ROLE SELECTION
// ══════════════════════════════════════════════════════════════════════════
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.07,
            vertical: 20,
          ),
          child: Column(
            children: [
              // Logo petit en haut
              GSLogoWidget(width: size.width * 0.22, height: size.width * 0.22, withText: false),
              const SizedBox(height: 6),
              GSLogoWidget(width: size.width * 0.5, textOnly: true),
              const SizedBox(height: 28),

              // Carte verte
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B5E20).withOpacity(0.4),
                      blurRadius: 24, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(context.read<AppProvider>().t('your_profile'),
                      style: const TextStyle(
                        color: Colors.white70, fontSize: 12,
                        letterSpacing: 2.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 18),
                    ...UserRole.values.map((r) => _RoleTile(role: r)),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: Text(context.read<AppProvider>().t('already_account'),
                        style: const TextStyle(
                          color: Colors.white70, fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white54)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final UserRole role;
  const _RoleTile({required this.role});

  String _roleLabel(AppProvider app) {
    switch (role) {
      case UserRole.agriculteur:    return app.t('role_agriculteur');
      case UserRole.exportateur:    return app.t('role_exportateur');
      case UserRole.verificateur:   return app.t('role_verificateur');
      case UserRole.transformateur: return app.t('role_transformateur');
      case UserRole.cooperative:    return app.t('role_cooperative');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => RegisterScreen(role: role))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(children: [
          Text(role.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(child: Text(_roleLabel(app),
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// REGISTER SCREEN — background full + logo SVG
// ══════════════════════════════════════════════════════════════════════════
class RegisterScreen extends StatefulWidget {
  final UserRole role;
  const RegisterScreen({super.key, required this.role});
  @override State<RegisterScreen> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen> {
  final _identCtrl  = TextEditingController();
  final _nomCtrl    = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _telCtrl    = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _loading = false;

  @override void dispose() {
    _identCtrl.dispose(); _nomCtrl.dispose(); _emailCtrl.dispose();
    _telCtrl.dispose(); _regionCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    AppState.user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: _nomCtrl.text.isNotEmpty ? _nomCtrl.text : 'Utilisateur',
      prenom: _identCtrl.text.isNotEmpty ? _identCtrl.text : 'Nouveau',
      email: _emailCtrl.text,
      telephone: _telCtrl.text,
      region: _regionCtrl.text.isNotEmpty ? _regionCtrl.text : 'Maritime',
      role: widget.role,
    );
    if (mounted) Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07, vertical: 16),
          child: Column(
            children: [
              // Header navigation
              Row(children: [
                _BackBtn(onTap: () => Navigator.pop(context)),
                const Spacer(),
                GSLogoWidget(
                  width: size.width * 0.15,
                  height: size.width * 0.15,
                  horizontal: true,
                ),
                const Spacer(),
                const SizedBox(width: 36),
              ]),
              const SizedBox(height: 20),

              // Carte inscription
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B5E20).withOpacity(0.4),
                      blurRadius: 24, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(context.read<AppProvider>().t('register_page'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65), fontSize: 11,
                        letterSpacing: 2.2)),
                    const SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(widget.role.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(widget.role.label,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 20),
                    _AuthInput(ctrl: _identCtrl, hint: context.read<AppProvider>().t('enter_id'),   icon: Icons.person_outline),
                    const SizedBox(height: 10),
                    _AuthInput(ctrl: _nomCtrl,   hint: context.read<AppProvider>().t('enter_name'),           icon: Icons.badge_outlined),
                    const SizedBox(height: 10),
                    _AuthInput(ctrl: _emailCtrl, hint: context.read<AppProvider>().t('enter_email'),         icon: Icons.email_outlined, type: TextInputType.emailAddress),
                    const SizedBox(height: 10),
                    _AuthInput(ctrl: _telCtrl,   hint: context.read<AppProvider>().t('enter_phone'),   icon: Icons.phone_outlined, type: TextInputType.phone),
                    const SizedBox(height: 10),
                    _AuthInput(ctrl: _regionCtrl,hint: context.read<AppProvider>().t('enter_region'),        icon: Icons.location_on_outlined),
                    const SizedBox(height: 10),
                    _AuthInput(ctrl: _passCtrl,  hint: context.read<AppProvider>().t('enter_password'), icon: Icons.lock_outline, obscure: true),
                    const SizedBox(height: 22),
                    _BrownButton(label: context.read<AppProvider>().t('register'), loading: _loading, onTap: _submit),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Text(context.read<AppProvider>().t('already_account'),
                  style: const TextStyle(
                    color: Color(0xFF1B5E20), fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// LOGIN SCREEN
// ══════════════════════════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final _identCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  UserRole _role = UserRole.agriculteur;
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    AppState.user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: 'Mensah',
      prenom: _identCtrl.text.isNotEmpty ? _identCtrl.text : 'Kofi',
      email: 'kofi@greenspace.tg',
      telephone: '+228 90 00 00 00',
      region: 'Maritime',
      role: _role,
    );
    if (mounted) Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
  }

  @override void dispose() {
    _identCtrl.dispose(); _passCtrl.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07, vertical: 16),
          child: Column(
            children: [
              Row(children: [
                _BackBtn(onTap: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()))),
                const Spacer(),
                GSLogoWidget(
                  width: size.width * 0.15,
                  height: size.width * 0.15,
                  horizontal: true,
                ),
                const Spacer(),
                const SizedBox(width: 36),
              ]),
              const SizedBox(height: 36),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B5E20).withOpacity(0.4),
                      blurRadius: 24, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('PAGE DE CONNEXION',
                      style: TextStyle(
                        color: Colors.white, fontSize: 12,
                        fontWeight: FontWeight.w700, letterSpacing: 2.2)),
                    const SizedBox(height: 22),

                    // Dropdown rôle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<UserRole>(
                          value: _role,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF2E7D32)),
                          style: const TextStyle(
                            color: GS.textDark, fontSize: 14),
                          items: UserRole.values.map((r) =>
                            DropdownMenuItem(value: r,
                              child: Row(children: [
                                Text(r.icon),
                                const SizedBox(width: 8),
                                Text(r.label),
                              ]))).toList(),
                          onChanged: (v) => setState(() => _role = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AuthInput(ctrl: _identCtrl, hint: context.read<AppProvider>().t('enter_id'), icon: Icons.person_outline),
                    const SizedBox(height: 12),
                    _AuthInput(ctrl: _passCtrl, hint: context.read<AppProvider>().t('enter_password'), icon: Icons.lock_outline, obscure: true),
                    const SizedBox(height: 26),
                    _BrownButton(label: context.read<AppProvider>().t('connect'), loading: _loading, onTap: _login),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const RoleSelectionScreen())),
                      child: Text(context.read<AppProvider>().t('no_account'),
                        style: const TextStyle(
                          color: Colors.white70, fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white54)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// WIDGETS RÉUTILISABLES AUTH
// ══════════════════════════════════════════════════════════════════════════
class _AuthInput extends StatelessWidget {
  final TextEditingController? ctrl;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? type;

  const _AuthInput({
    this.ctrl, required this.hint, this.icon,
    this.obscure = false, this.type,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    obscureText: obscure,
    keyboardType: type,
    style: const TextStyle(fontSize: 14, color: GS.textDark),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: GS.textLight, fontSize: 13),
      prefixIcon: icon != null
          ? Icon(icon, size: 18, color: const Color(0xFF388E3C))
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5)),
    ),
  );
}

class _BrownButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _BrownButton({required this.label, required this.loading, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: double.infinity, height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF6D4C1F),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E3010).withOpacity(0.45),
            blurRadius: 12, offset: const Offset(0, 5)),
        ],
      ),
      child: Center(
        child: loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
            : Text(label,
                style: const TextStyle(
                  color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ),
    ),
  );
}

class _BackBtn extends StatelessWidget {
  final VoidCallback? onTap;
  const _BackBtn({this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap ?? () => Navigator.pop(context),
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
        ],
      ),
      child: const Icon(Icons.arrow_back_ios_new,
        size: 15, color: GS.textDark),
    ),
  );
}
