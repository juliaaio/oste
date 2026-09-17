import 'package:flutter/material.dart';

class NutrisiPage extends StatelessWidget {
  const NutrisiPage({super.key});

  static const List<_NutritionItem> _items = [
    _NutritionItem(
      icon: Icons.local_drink_outlined,
      iconColor: Color(0xFFFFC107),
      iconBg: Color(0xFFFFF8E1),
      title: 'Sumber Kalsium',
      description: 'Makanan dan minuman tinggi kalsium untuk tulang kuat.',
    ),
    _NutritionItem(
      icon: Icons.set_meal_outlined,
      iconColor: Color(0xFF90CAF9),
      iconBg: Color(0xFFE3F2FD),
      title: 'Sumber Vitamin D',
      description:
          'Pilihan makanan dan minuman untuk membantu penyerapan kalsium.',
    ),
    _NutritionItem(
      icon: Icons.eco_outlined,
      iconColor: Color(0xFF66BB6A),
      iconBg: Color(0xFFE8F5E9),
      title: 'Sayuran dan Buah-buahan',
      description:
          'Kaya akan vitamin dan mineral penting untuk kesehatan tulang.',
    ),
    _NutritionItem(
      icon: Icons.grain_outlined,
      iconColor: Color(0xFFBCAAA4),
      iconBg: Color(0xFFEFEBE9),
      title: 'Kacang-kacangan\ndan Biji-bijian',
      description: 'Sumber nutrisi yang baik untuk tulang.',
    ),
    _NutritionItem(
      icon: Icons.water_drop_outlined,
      iconColor: Color(0xFF64B5F6),
      iconBg: Color(0xFFE3F2FD),
      title: 'Minuman yang Disarankan',
      description: 'Minuman sehat yang mendukung kesehatan tulang.',
    ),
    _NutritionItem(
      icon: Icons.not_interested_rounded,
      iconColor: Color(0xFFEF5350),
      iconBg: Color(0xFFFFEBEE),
      title: 'Makanan dan Minuman\nyang Sebaiknya Dibatasi',
      description: 'Hindari konsumsi berlebih agar tulang tetap sehat.',
    ),
  ];

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
          'Makanan & Minuman',
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
            const _SectionTitle(title: 'Kategori Topik'),
            const SizedBox(height: 12),
            ...List.generate(
              _items.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _NutritionCard(item: _items[index]),
              ),
            ),
            const SizedBox(height: 4),
            const _TipsCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero card
// ---------------------------------------------------------------------------
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/education/nutrition.png',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECB3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_outlined,
                  size: 38,
                  color: Color(0xFFFFC107),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilihan Makanan & Minuman untuk Tulang Sehat',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ketahui asupan gizi yang baik untuk menjaga kepadatan tulang dan mencegah osteoporosis.',
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
// Section title
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
class _NutritionItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;

  const _NutritionItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });
}

// ---------------------------------------------------------------------------
// Nutrition card
// ---------------------------------------------------------------------------
class _NutritionCard extends StatelessWidget {
  final _NutritionItem item;

  const _NutritionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              size: 26,
              color: item.iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
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
// Tips card
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Kombinasikan pola makan seimbang dengan olahraga rutin untuk hasil yang lebih optimal.',
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
