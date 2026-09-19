import 'package:flutter/material.dart';

class PenyebabPage extends StatelessWidget {
  const PenyebabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFF8EC),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Paragraf pembuka
            const Text(
              'Osteoporosis dapat disebabkan oleh berbagai faktor. Beberapa faktor tidak dapat diubah, namun banyak juga yang dapat dikendalikan dengan gaya hidup sehat.',
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Section "Faktor yang Tidak Dapat Diubah"
            _buildSectionHeader('Faktor yang Tidak Dapat Diubah'),
            const SizedBox(height: 14),

            // 3. Card Genetik, Usia, Jenis Kelamin
            const _FactorCard(
              icon: Icons.hub_rounded,
              title: 'Faktor Genetik',
              description:
                  'Riwayat keluarga dengan osteoporosis meningkatkan risiko.',
            ),
            const SizedBox(height: 12),
            const _FactorCard(
              icon: Icons.person_rounded,
              title: 'Usia',
              description:
                  'Risiko meningkat seiring bertambahnya usia, terutama setelah usia 50 tahun.',
            ),
            const SizedBox(height: 12),
            const _FactorCard(
              icon: Icons.female_rounded,
              iconColor: Color(0xFFF43F5E),
              iconBgColor: Color(0xFFFFF0F2),
              title: 'Jenis Kelamin',
              description:
                  'Wanita, terutama setelah menopause, lebih berisiko karena penurunan hormon estrogen.',
            ),
            const SizedBox(height: 24),

            // 4. Section "Faktor yang Dapat Diubah"
            _buildSectionHeader('Faktor yang Dapat Diubah'),
            const SizedBox(height: 14),

            // 5. Card-card faktor risiko lainnya (Grouped container sesuai screenshot)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFDE68A).withValues(alpha: 0.7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE5A124).withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  _FactorCard(
                    icon: Icons.restaurant_rounded,
                    title: 'Asupan Kalsium dan Vitamin D yang rendah',
                    isGrouped: true,
                    showDivider: true,
                  ),
                  _FactorCard(
                    icon: Icons.directions_run_rounded,
                    title: 'Kurang aktivitas fisik',
                    isGrouped: true,
                    showDivider: true,
                  ),
                  _FactorCard(
                    icon: Icons.smoking_rooms_rounded,
                    title: 'Kebiasaan merokok',
                    isGrouped: true,
                    showDivider: true,
                  ),
                  _FactorCard(
                    icon: Icons.liquor_rounded,
                    title: 'Konsumsi alkohol berlebihan',
                    isGrouped: true,
                    showDivider: true,
                  ),
                  _FactorCard(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Berat badan terlalu rendah',
                    isGrouped: true,
                    showDivider: true,
                  ),
                  _FactorCard(
                    icon: Icons.medication_rounded,
                    title:
                        'Penggunaan obat tertentu dalam jangka panjang (seperti kortikosteroid)',
                    isGrouped: true,
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 6. Card "Ingat!" di bawah
            const _ReminderCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFE5A124),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

/// Widget kartu faktor risiko (bisa berupa standalone card maupun row item grouped)
class _FactorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Color? iconColor;
  final Color? iconBgColor;
  final bool isGrouped;
  final bool showDivider;

  const _FactorCard({
    required this.icon,
    required this.title,
    this.description,
    this.iconColor,
    this.iconBgColor,
    this.isGrouped = false,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? const Color(0xFFE5A124);
    final effectiveIconBgColor = iconBgColor ?? const Color(0xFFFFF4D6);

    if (isGrouped) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: effectiveIconBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: const Color(0xFFFDE68A).withValues(alpha: 0.35),
              indent: 16,
              endIndent: 16,
            ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5A124).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: effectiveIconBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: effectiveIconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card motivasi/pengingat di bagian bawah
class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5A124).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFFF7C948),
            size: 28,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingat!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Meski ada faktor yang tidak dapat diubah, risiko osteoporosis tetap dapat dikurangi dengan gaya hidup sehat.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}