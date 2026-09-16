import 'package:flutter/material.dart';

class VitaminPage extends StatelessWidget {
  const VitaminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Color(0xFF1A1A1A)),
        title: const Text(
          'Vitamin',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroCard(),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Jenis Vitamin yang Direkomendasikan'),
            const SizedBox(height: 12),
            ..._vitamins.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _VitaminCard(vitamin: v),
                )),
            const SizedBox(height: 4),
            const _TipsCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static const List<_VitaminItem> _vitamins = [
    _VitaminItem(
      icon: Icons.wb_sunny_outlined,
      iconColor: Color(0xFFFFC107),
      iconBg: Color(0xFFFFF8E1),
      title: 'Vitamin D',
      description: 'Membantu penyerapan kalsium dan menjaga kekuatan tulang.',
    ),
    _VitaminItem(
      icon: Icons.water_drop_outlined,
      iconColor: Color(0xFF90CAF9),
      iconBg: Color(0xFFE3F2FD),
      title: 'Kalsium',
      description: 'Mineral utama pembentuk tulang yang kuat.',
    ),
    _VitaminItem(
      icon: Icons.spa_outlined,
      iconColor: Color(0xFFBCAAA4),
      iconBg: Color(0xFFEFEBE9),
      title: 'Magnesium',
      description: 'Membantu menjaga struktur tulang dan fungsi otot.',
    ),
    _VitaminItem(
      icon: Icons.bubble_chart_outlined,
      iconColor: Color(0xFFFF7043),
      iconBg: Color(0xFFFBE9E7),
      title: 'Vitamin C',
      description: 'Berperan dalam pembentukan kolagen untuk tulang yang sehat.',
    ),
    _VitaminItem(
      icon: Icons.eco_outlined,
      iconColor: Color(0xFF66BB6A),
      iconBg: Color(0xFFE8F5E9),
      title: 'Vitamin K',
      description: 'Membantu pembentukan protein dalam tulang.',
    ),
  ];
}

// ---------------------------------------------------------------------------
// Hero card (top card with illustration + description)
// ---------------------------------------------------------------------------
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Illustration placeholder
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/images/education/vitamins.png',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.medication_liquid_outlined,
                size: 38,
                color: Color(0xFFFFC107),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vitamin & Suplemen yang Direkomendasikan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pelajari berbagai vitamin dan suplemen penting yang dapat membantu menjaga kepadatan tulang dan mencegah osteoporosis.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF757575),
                        height: 1.5,
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

// ---------------------------------------------------------------------------
// Section title in amber color
// ---------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFFFFC107),
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------
class _VitaminItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;

  const _VitaminItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });
}

// ---------------------------------------------------------------------------
// Vitamin card
// ---------------------------------------------------------------------------
class _VitaminCard extends StatelessWidget {
  final _VitaminItem vitamin;

  const _VitaminCard({required this.vitamin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: vitamin.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              vitamin.icon,
              size: 26,
              color: vitamin.iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vitamin.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  vitamin.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9E9E9E),
                        height: 1.45,
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

// ---------------------------------------------------------------------------
// Tips card with light yellow background
// ---------------------------------------------------------------------------
class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              size: 26,
              color: Color(0xFFFFC107),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Konsumsi vitamin dan suplemen sesuai kebutuhan dan anjuran dokter untuk hasil yang lebih optimal.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF757575),
                        height: 1.45,
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