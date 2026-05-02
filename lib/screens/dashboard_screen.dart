import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = AppData.dashboardStats;
    final regions = AppData.regions;

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      appBar: const GreenAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.dashboard_outlined, color: AppColors.primaryGreen, size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard National',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Ministère de l\'Agriculture - Togo',
                        style: TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.6,
              children: [
                StatCard(
                  label: 'Lots enregistrés',
                  value: '${stats['lots']}',
                  delta: '+4%',
                  icon: Icons.inventory_2_outlined,
                ),
                StatCard(
                  label: 'Exportateurs',
                  value: '${stats['exportateurs']}',
                  delta: '+8%',
                  icon: Icons.local_shipping_outlined,
                ),
                StatCard(
                  label: 'Certifications',
                  value: '${stats['certifications']}',
                  delta: '+2%',
                  icon: Icons.verified_outlined,
                ),
                StatCard(
                  label: 'Zones actives',
                  value: '${stats['zones']}',
                  icon: Icons.map_outlined,
                ),
                StatCard(
                  label: 'Agriculteurs',
                  value: '${stats['agriculteurs']}',
                  delta: '+oja%',
                  icon: Icons.grass_outlined,
                ),
                StatCard(
                  label: 'OJA Compliance',
                  value: '${stats['oja']}%',
                  icon: Icons.shield_outlined,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Zones de production
            const SectionTitle(title: 'Zones de production'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: regions.map((r) => _RegionRow(region: r)).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Carte des zones placeholder
            const SectionTitle(title: 'Carte des zones'),
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Container(
                      color: const Color(0xFFE8F4EA),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 48, color: AppColors.primaryGreen),
                            SizedBox(height: 8),
                            Text(
                              '34 zones actives',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Sur l\'ensemble du Togo',
                              style: TextStyle(fontSize: 12, color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Fake map pins
                    Positioned(
                      top: 40,
                      left: 80,
                      child: _MapPin(color: AppColors.primaryGreen),
                    ),
                    Positioned(
                      top: 70,
                      right: 90,
                      child: _MapPin(color: AppColors.brown),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 140,
                      child: _MapPin(color: AppColors.primaryGreenLight),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Impact social
            const SectionTitle(title: 'Impact social et économique'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _ImpactTile(
                    label: 'Agriculteurs',
                    value: '2,456',
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 16),
                  _ImpactTile(
                    label: 'OJA compliant',
                    value: '98.7%',
                    color: AppColors.statusVerified,
                  ),
                  const SizedBox(width: 16),
                  _ImpactTile(
                    label: 'Commerce digitale',
                    value: '0%',
                    color: AppColors.statusPending,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Production mensuelle chart
            const SectionTitle(title: 'Production mensuelle (tonnes)'),
            const SizedBox(height: 12),
            Container(
              height: 160,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _SimpleBarChart(),
            ),

            const SizedBox(height: 20),

            // Répartition certifications
            const SectionTitle(title: 'Répartition certifications'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Simple donut placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryGreen, width: 12),
                    ),
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brown.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AppData.certificationRepartition.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: e.key == 'Bio'
                                    ? AppColors.primaryGreen
                                    : e.key == 'Fair Trade'
                                        ? AppColors.brown
                                        : AppColors.textLight,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${e.key} · ${e.value}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _RegionRow extends StatelessWidget {
  final RegionStats region;
  const _RegionRow({required this.region});

  @override
  Widget build(BuildContext context) {
    final maxLots = 433;
    final progress = region.lots / maxLots;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                region.nom,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              Text(
                '${region.lots} lots',
                style: const TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;
  const _MapPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const Center(
        child: Icon(Icons.location_on, color: Colors.white, size: 12),
      ),
    );
  }
}

class _ImpactTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ImpactTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = AppData.productionMensuelle;
    final maxVal = 160.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final height = ((item['tonnes'] as int) / maxVal) * 100.0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${item['tonnes']}',
                  style: const TextStyle(fontSize: 9, color: AppColors.textLight),
                ),
                const SizedBox(height: 3),
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['mois'] as String,
                  style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
