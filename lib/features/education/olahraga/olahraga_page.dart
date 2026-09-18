import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Data olahraga
// ---------------------------------------------------------------------------
final List<Map<String, dynamic>> _exerciseData = [
  {
    'icon': Icons.sports_tennis,
    'title': 'Tenis',
    'description': 'Meningkatkan kepadatan tulang sejak usia muda.',
  },
  {
    'icon': Icons.fitness_center,
    'title': 'Angkat Beban',
    'description': 'Membentuk dan menjaga kepadatan tulang.',
  },
  {
    'icon': Icons.self_improvement,
    'title': 'Yoga',
    'description': 'Meningkatkan keseimbangan dan fleksibilitas tubuh.',
  },
  {
    'icon': Icons.directions_walk,
    'title': 'Berjalan Kaki',
    'description':
        'Olahraga sederhana yang efektif untuk menjaga tulang tetap kuat.',
  },
];

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
class OlahragaPage extends StatelessWidget {
  const OlahragaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF222222),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Olahraga',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Card informasi
              const _HeaderCard(),

              const SizedBox(height: 28),

              // 2. Judul section
              const Text(
                'Jenis Olahraga yang Direkomendasikan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 16),

              // 3. Daftar olahraga + tips card
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...List.generate(
                    _exerciseData.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ExerciseCard(
                        icon: _exerciseData[index]['icon'] as IconData,
                        title: _exerciseData[index]['title'] as String,
                        description:
                            _exerciseData[index]['description'] as String,
                      ),
                    ),
                  ),
                  const _TipsCard(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header card
// ---------------------------------------------------------------------------
class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/exercise.png',
            width: 90,
            height: 90,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECB3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                size: 48,
                color: Color(0xFFF7C948),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Olahraga untuk Tulang Lebih Kuat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Aktivitas fisik secara rutin membantu meningkatkan kepadatan tulang, memperkuat otot, menjaga keseimbangan tubuh, dan menurunkan risiko osteoporosis serta patah tulang.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
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
// Exercise card
// ---------------------------------------------------------------------------
class _ExerciseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ExerciseCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 28,
              color: const Color(0xFFF7C948),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.wb_sunny,
            size: 30,
            color: Color(0xFFF7C948),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tips',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Lakukan olahraga secara rutin, mulai sesuai kemampuan tubuh, dan kombinasikan dengan pola makan sehat untuk hasil yang lebih optimal.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
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
