import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'agriculture_screen.dart';
import 'verification_screen.dart';
import 'transformateur_screen.dart';
import 'coop_export_screens.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final UserRole role;
  const MainShell({super.key, required this.role});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  List<_NavItem> get _navItems {
    switch (widget.role) {
      case UserRole.agriculteur:
        return const [
          _NavItem(Icons.home_outlined, 'Accueil'),
          _NavItem(Icons.grass_outlined, 'Agriculture'),
          _NavItem(Icons.group_outlined, 'Coopérative'),
          _NavItem(Icons.local_shipping_outlined, 'Exportateur'),
          _NavItem(Icons.verified_outlined, 'Vérification'),
        ];
      case UserRole.exportateur:
        return const [
          _NavItem(Icons.home_outlined, 'Accueil'),
          _NavItem(Icons.grass_outlined, 'Agriculture'),
          _NavItem(Icons.group_outlined, 'Coopérative'),
          _NavItem(Icons.local_shipping_outlined, 'Exportateur'),
          _NavItem(Icons.verified_outlined, 'Vérification'),
        ];
      case UserRole.verificateur:
        return const [
          _NavItem(Icons.home_outlined, 'Accueil'),
          _NavItem(Icons.grass_outlined, 'Agriculture'),
          _NavItem(Icons.group_outlined, 'Coopérative'),
          _NavItem(Icons.local_shipping_outlined, 'Exportateur'),
          _NavItem(Icons.verified_outlined, 'Vérification'),
        ];
      case UserRole.transformateur:
        return const [
          _NavItem(Icons.home_outlined, 'Accueil'),
          _NavItem(Icons.grass_outlined, 'Agriculture'),
          _NavItem(Icons.group_outlined, 'Coopérative'),
          _NavItem(Icons.local_shipping_outlined, 'Exportateur'),
          _NavItem(Icons.verified_outlined, 'Vérification'),
        ];
      case UserRole.cooperative:
        return const [
          _NavItem(Icons.home_outlined, 'Accueil'),
          _NavItem(Icons.grass_outlined, 'Agriculture'),
          _NavItem(Icons.group_outlined, 'Coopérative'),
          _NavItem(Icons.local_shipping_outlined, 'Exportateur'),
          _NavItem(Icons.verified_outlined, 'Vérification'),
        ];
    }
  }

  Widget get _currentScreen {
    switch (_currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const AgricultureScreen();
      case 2:
        return const CooperativeScreen();
      case 3:
        return const ExportateurScreen();
      case 4:
        return _getVerificationScreen();
      default:
        return const DashboardScreen();
    }
  }

  Widget _getVerificationScreen() {
    switch (widget.role) {
      case UserRole.verificateur:
        return const VerificationScreen();
      case UserRole.transformateur:
        return const TransformateurScreen();
      default:
        return const VerificationScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _currentScreen,
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final Function(int) onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: selected ? 40 : 0,
                          height: selected ? 3 : 0,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          item.icon,
                          size: 22,
                          color: selected
                              ? AppColors.primaryGreen
                              : AppColors.textLight,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 9,
                            color: selected
                                ? AppColors.primaryGreen
                                : AppColors.textLight,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
